module "stack_dependencies" {
  for_each = local.dependencies
  source   = "./modules/stack_dependencies"

  stack_id           = spacelift_stack.dynamic_stacks[replace(each.value.stack, "${local.product}-", "")].id
  dependent_stack_id = spacelift_stack.dynamic_stacks[replace(each.value.dependent_stack, "${local.product}-", "")].id
  references         = each.value.dependencies
}
