output "stack_ids" {
  description = "Map of folder path to Spacelift stack ID"
  value       = { for k, v in spacelift_stack.dynamic_stacks : k => v.id }
}

output "stack_count" {
  description = "Total number of dynamically created stacks"
  value       = length(spacelift_stack.dynamic_stacks)
}
