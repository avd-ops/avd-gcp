# Instructions for AI agents

For any coding agent: Claude Code, Gemini CLI, Codex and others. Read this file first, then
[CLAUDE.md](CLAUDE.md). Gemini CLI loads this file through [GEMINI.md](GEMINI.md). Where they
differ, the more specific rule wins, and the owner's own words win over all of them.

## How to make a change

- Say what you assumed. When the ask leaves a detail open, pick the reasonable default, say which,
  and keep going.
- Write the least code that does the job: no speculative features, options, or abstractions.
- Touch only what the task needs and match the style around it.
- Before you start, name the check that proves the task is done, and don't call it done until it
  passes in front of you.

## Family rules

- **No spend without the owner's exact go.** No GCP or Azure cloud run without a written cost
  estimate and the owner typing `go batch <id> $<total>`.
- **Never leave the meter running.** Compute Engine VMs use Cloud Instance Schedules; NetApp
  Volumes default to disabled (`enable_fslogix_netapp = false`) in `lab` profile.
- **Never delete the last copy** of data without a checked copy elsewhere or `-DiscardLastCopy`.
- **No secrets, IDs or names.** No GCP project IDs/numbers, Azure tenant/subscription/object/client
  IDs, domains, IPs, emails, secrets, or employer/customer names in the repo, commits, issues, or PRs.
  Use placeholders (`contoso.com`, `<gcp-project-id>`, `<tenant-id>`, `10.x`).
- **Pull requests only; the owner merges.** Work on a branch and open a PR; never push directly to `main`.
- **Stay in your lane.** `avd-gcp` owns the GCP compute, network, storage, Packer image, and Arc
  onboarding plane for AVD Hybrid. Azure-side AVD host pools and workspaces live in `avd-azure` /
  `avd-landing-zone`.
- **Personal project, not for production, as is, not affiliated with the author's employer,
  Liquidware, ServiceNow, Google or Microsoft.**
- **American English** in docs, output, and comments.

## Checks to run

```bash
for d in modules/*/ environments/example/*/; do
  (cd "$d" && terraform init -backend=false && terraform validate && terraform test)
done
```
