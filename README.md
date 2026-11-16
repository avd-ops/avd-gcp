# avd-gcp

Part of [avd-ops](https://avd-ops.dev/), the open toolkit for Azure Virtual Desktop.

Google Cloud Platform (GCP) session-host control plane (`avd-gcp`) for **Azure Virtual Desktop (AVD) Hybrid** (ADR 0015). Provisions GCP Compute Engine session hosts, VPC/Cloud NAT egress, optional Google Cloud NetApp Volumes (SMB) for FSLogix, and Azure Arc + `Microsoft.AzureVirtualDesktop.CloudDeviceExtension` onboarding into an Azure-hosted AVD Hybrid host pool.

> [!WARNING]
> **Personal project. Research and learning only. Not for production. No warranty.**
>
> - This is my own personal project, built on my own time **for research and learning**. It is **not affiliated with, endorsed by or supported by my employer**, Liquidware, ServiceNow, Google or Microsoft, and it does not represent their views, products or guidance.
> - **Do not run any of it in production** or against projects, subscriptions, or tenants that matter. Test it first in a dedicated lab environment.
> - It is provided **"as is", without warranty of any kind**, under the [MIT License](LICENSE). You use it at your own risk.
> - **Contributions and forks are welcome and encouraged.** See [Contributing](#contributing).

## How it connects

| Direction | Repo | Relationship |
|---|---|---|
| Front door | [avd-ops](https://github.com/avd-ops/avd-ops#readme) | Overview and platform decisions |
| Orchestrator | [avd-landing-zone](https://github.com/avd-ops/avd-landing-zone#readme) | Consumes `gcp-outputs.json` (`C32`) alongside Azure Hybrid host pools |
| Azure sibling | [avd-azure](https://github.com/avd-ops/avd-azure#readme) | Hosts the Azure-side AVD Hybrid host pool and workspace |
| Inventory | [avd-current-state](https://github.com/avd-ops/avd-current-state#readme) | Collects Arc-enabled hybrid session host state |
| AWS sibling | [avd-aws](https://github.com/avd-ops/avd-aws#readme) | Companion AWS EC2 session-host control plane for AVD Hybrid |

## What it does

- **Networking (`modules/network`)**: Deploys a dedicated GCP VPC and private subnet with Cloud Router and Cloud NAT for outbound-only TCP `443` (Azure Arc + AVD service endpoints) and optional outbound UDP `3478` (RDP Shortpath). Blocks inbound internet RDP (`3389`).
- **FSLogix Storage (`modules/storage`)**: Optional Google Cloud NetApp Volumes (SMB) for AD-joined estates (`enable_fslogix_netapp = false` by default in `lab` profile; Entra-joined-only estates use local profiles or Azure Files with Entra Kerberos).
- **Session Hosts (`modules/compute`)**: Deploys Shielded Compute Engine VMs (Secure Boot + vTPM + Integrity Monitoring) running **single-session Windows 11 Enterprise** with **Entra ID join**, Cloud Instance Schedules (auto-stop/start, since AVD Autoscale and Start VM on Connect are unsupported on Hybrid), and idempotent Azure Arc + AVD `CloudDeviceExtension` registration (`scripts/arc-onboard.ps1`).
- **Golden Image (`docs/image-pipeline.md`, `packer/avd-win11-gcp`)**: Because GCP `windows-cloud` only publishes Windows Server, Windows 11 Enterprise (single-session) is built in Azure (or locally) as a generalized VHD, transferred to GCS, and imported into Compute Engine via BYOL (`windows-11-x64-byol`).
- **Contracts**: Emits `gcp-outputs.json` matching contract C32 (`avd-gcp-outputs/v1`) for [avd-azure](https://github.com/avd-ops/avd-azure#readme), [avd-landing-zone](https://github.com/avd-ops/avd-landing-zone#readme), and [avd-current-state](https://github.com/avd-ops/avd-current-state#readme).

## Quick start (offline validation)

```bash
for d in modules/*/ environments/example/*/; do
  (cd "$d" && terraform init -backend=false >/dev/null && terraform validate && terraform test)
done
```

## Docs

- Image pipeline: [docs/image-pipeline.md](docs/image-pipeline.md)
- Agent instructions & guardrails: [AGENTS.md](AGENTS.md)

## Contributing

Fork it, open an issue or a pull request. Follow the family guardrails in [AGENTS.md](AGENTS.md): no GCP project IDs, tenant/subscription IDs, secrets, domains, or customer names, and propose changes via pull request only. Contributions are accepted under the [MIT License](LICENSE).

## License and disclaimer

[MIT](LICENSE). Personal project, not for production, provided as is, not affiliated with the author's employer, Liquidware, ServiceNow, Google or Microsoft.
