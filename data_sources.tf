data "spacelift_worker_pool" "private" {
  worker_pool_id = var.worker_pool_id
}

data "spacelift_policy" "ignore_changes_outside_root" {
  policy_id = var.policy_ignore_outside_root_id
}

data "spacelift_policy" "trivy" {
  policy_id = var.policy_trivy_id
}

data "spacelift_context" "shared" {
  context_id = var.shared_context_id
}

# Look up each account's Spacelift space by name
data "spacelift_space" "accounts" {
  for_each = local.accounts

  space_id = each.value.space_id
}
