variable "stack_id" {
  description = "ID of the stack that depends on another"
  type        = string
}

variable "dependent_stack_id" {
  description = "ID of the stack being depended on"
  type        = string
}

variable "references" {
  description = "Map of output_name to input_name for passing values between stacks"
  type        = map(string)
  default     = {}
}
