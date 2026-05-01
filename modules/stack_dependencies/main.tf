resource "spacelift_stack_dependency" "this" {
  stack_id            = var.stack_id
  depends_on_stack_id = var.dependent_stack_id
}

resource "spacelift_stack_dependency_reference" "this" {
  for_each = var.references

  stack_dependency_id = spacelift_stack_dependency.this.id
  output_name         = each.key
  input_name          = each.value
}
