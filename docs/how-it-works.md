# How it works

## Auto-discovery

The core logic lives in `locals.tf`. It uses Terraform's `fileset()` to find every `main.tf` in the repo tree, strips the filename to get folder paths, then filters out ignored paths.

```
fileset(".", "**/main.tf")
→ ["aws/production/vpc/main.tf", "aws/production/eks/cluster/main.tf", ...]
→ strip /main.tf → ["aws/production/vpc", "aws/production/eks/cluster", ...]
→ filter ignore_paths → final set
```

Each item in the final set becomes a Spacelift stack with `project_root` set to that path.

## Why this pattern

Without this, every new service requires manually creating a Spacelift stack in the UI. With auto-discovery, the convention is the configuration — just follow the folder structure.

## Stack naming

Stack names follow the pattern `{product}-{path-with-slashes-as-dashes}`:

- `aws/production/vpc` → `my-org-aws-production-vpc`
- `aws/production/eks/cluster` → `my-org-aws-production-eks-cluster`

## Dependencies

When stack B needs an output from stack A, add a `dependencies.yml` in B's folder:

```yaml
# aws/production/eks/apps/dependencies.yml
aws/production/eks/cluster:
  cluster_name: TF_VAR_cluster_name
  cluster_endpoint: TF_VAR_cluster_endpoint
```

Spacelift passes the output from A to B as an environment variable before B runs.

## Administrative stack

The root of this repo is itself a Spacelift stack (administrative). It manages all other stacks. When you push to main, the administrative stack runs and reconciles the desired set of stacks with what exists in Spacelift.
