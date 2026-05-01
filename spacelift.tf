# Dynamically create one Spacelift stack per discovered folder
resource "spacelift_stack" "dynamic_stacks" {
  for_each = local.stacks_clean_folders_filtered

  name                    = format("%s-%s", local.product, replace(each.key, "/", "-"))
  administrative          = contains(local.administrative_paths, each.key)
  autodeploy              = true
  enable_local_preview    = true
  project_root            = each.key
  repository              = local.repository
  branch                  = "main"
  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "1.11.0"
  worker_pool_id          = data.spacelift_worker_pool.private.id

  labels = [
    "dynamic",
    local.product,
    element(split("/", each.key), 1),
  ]

  github_enterprise {
    namespace = "your-github-org"
    id        = "your-github-app-id"
  }
}

# Trigger initial run on each newly created stack
resource "spacelift_run" "initial" {
  for_each = local.stacks_clean_folders_filtered

  stack_id = spacelift_stack.dynamic_stacks[each.key].id
}

# Attach the "ignore changes outside root" policy to every stack
# so a change in aws/production only triggers aws/production stacks
resource "spacelift_policy_attachment" "ignore_outside_root" {
  for_each = local.stacks_clean_folders_filtered

  policy_id = data.spacelift_policy.ignore_changes_outside_root.id
  stack_id  = spacelift_stack.dynamic_stacks[each.key].id
}

# Attach Trivy security scanning policy
resource "spacelift_policy_attachment" "trivy" {
  for_each = local.stacks_clean_folders_filtered

  policy_id = data.spacelift_policy.trivy.id
  stack_id  = spacelift_stack.dynamic_stacks[each.key].id
}

# Attach shared context (environment variables, mounted files)
resource "spacelift_context_attachment" "shared" {
  for_each = local.stacks_clean_folders_filtered

  context_id = data.spacelift_context.shared.id
  stack_id   = spacelift_stack.dynamic_stacks[each.key].id
}
