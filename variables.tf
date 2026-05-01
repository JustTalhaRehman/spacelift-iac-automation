variable "worker_pool_id" {
  description = "Spacelift worker pool ID for private runners"
  type        = string
}

variable "policy_ignore_outside_root_id" {
  description = "Spacelift policy ID for ignoring changes outside project root"
  type        = string
}

variable "policy_trivy_id" {
  description = "Spacelift policy ID for Trivy security scanning"
  type        = string
}

variable "shared_context_id" {
  description = "Spacelift context ID containing shared environment variables"
  type        = string
}
