# Image Pipeline Spec: Azure-Built Windows 11 Enterprise → GCP

GCP's `windows-cloud` public image project only publishes Windows Server images (2016–2025). Because **AVD Hybrid** does not support Windows 11 Enterprise multi-session, Entra-only Windows 11 Enterprise (single-session) session hosts on GCP must use a **custom BYOL imported image**.

## Pipeline Overview

1. **Build in Azure (`azure-arm` Packer or existing single-session image)**
   - **Base SKU**: Single-session `microsoftwindowsdesktop:windows-11:win11-24h2-ent:latest` (never `win11-24h2-ent-ms`).
   - **Pre-staging**: Stage `AzureConnectedMachineAgent.msi` (and optionally WDOT optimization), then remove/disable `WindowsAzureGuestAgent` before generalizing so the VM does not poll Azure IMDS (`169.254.169.254`) from GCP.
   - **Generalize**: Run `sysprep /generalize /oobe /shutdown /mode:vm` and capture/export a fixed-size `.vhd` page blob.

2. **Transfer `.vhd` to Google Cloud Storage**
   - Copy the generalized `.vhd` from Azure Storage (via short-lived SAS URL) to a temporary GCS bucket (`gcloud storage cp` / `azcopy`).
   - Revoke the SAS token and delete the Azure staging VHD/snapshot immediately after transfer.

3. **Import into Compute Engine (BYOL)**
   - Run GCP's image import (`gcloud migration vms image-imports` with `--license-type=compute-engine-license-type-byol`, or `gcloud compute images import <image-name> --source-file=gs://<bucket>/<image>.vhd --os=windows-11-x64-byol --guest-os-features=UEFI_COMPATIBLE`).
   - GCP's importer translates the VHD, injects VirtIO/NetKVM drivers, and installs the Compute Engine Guest Environment.
   - Delete the temporary `.vhd` from GCS once the Compute Engine image is ready.

4. **Optionally harden in GCP (`packer/avd-win11-gcp`) & deploy (`01-hybrid`)**
   - Pass the imported image family/name as `source_image` to `environments/example/01-hybrid`.
   - Note: `enable_fslogix_netapp` remains `false` (local profiles) for Entra-joined-only estates.
