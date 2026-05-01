# Spacelift IaC Automation

Meta-infrastructure as code — Terraform managing Terraform stacks via [Spacelift](https://spacelift.io). Instead of manually creating stacks in the Spacelift UI, this config auto-discovers every folder containing a `main.tf` in your repo and creates a Spacelift stack for it dynamically.

Add a new account or service? Just drop a `main.tf` in the right folder, push, and the stack appears automatically.

## What this does

1. Scans the repository for every `main.tf` (excluding a list of ignore paths)
2. Creates a `spacelift_stack` for each discovered path
3. Attaches shared policies (Trivy security scanning, drift detection)
4. Wires stack dependencies from per-folder `dependencies.yml` files
5. Triggers an initial run on each newly created stack

## Structure

```
spacelift-iac-automation/
├── main.tf                 # Terraform + Spacelift provider config
├── spacelift.tf            # Dynamic stack creation
├── stack_dependencies.tf   # Wires dependencies between stacks
├── locals.tf               # Folder discovery logic
├── data_sources.tf         # Spacelift data lookups
├── providers.tf            # Provider config
├── variables.tf
├── outputs.tf
├── configs/
│   └── accounts.yml        # Account definitions (used in stack naming)
└── modules/
    └── stack_dependencies/ # Reusable module for stack dependency wiring
```

## Prerequisites

- A [Spacelift](https://spacelift.io) account
- Spacelift API key (set as `SPACELIFT_API_KEY_ID` and `SPACELIFT_API_KEY_SECRET` env vars)
- Terraform >= 1.5.0

## Quick Start

### 1. Configure your accounts

Edit `configs/accounts.yml`:

```yaml
my-org-aws-production:
  account_id: "333333333333"
  space_id: "my-org-aws-production-01EXAMPLE"
```

### 2. Update locals

In `locals.tf`, set your product prefix and repository name:

```hcl
locals {
  product    = "my-org"
  repository = "my-iac-repo"
}
```

### 3. Add ignore paths

Any folders you don't want auto-stacked go in `ignore_paths`:

```hcl
ignore_paths = ["main.tf", "**/.terraform/**", "some-manual-folder"]
```

### 4. Apply

```bash
terraform init
terraform plan
terraform apply
```

## Stack dependencies

To define that stack B should apply after stack A, add a `dependencies.yml` in stack B's folder:

```yaml
# aws/production/eks/apps/dependencies.yml
aws/production/eks/cluster:
  - output: cluster_name
    input: TF_VAR_cluster_name
```

The `stack_dependencies.tf` and `modules/stack_dependencies` pick this up automatically.

## Policies

Every stack gets two policies attached:

- **Ignore changes outside root** — a stack only triggers when files inside its `project_root` change
- **Trivy security scan** — runs Trivy against the Terraform plan before applying

## Worker pools

Stacks run on a private worker pool (self-hosted runners in your VPC). Update `data_sources.tf` with your worker pool ID or switch to Spacelift's public workers for testing.
