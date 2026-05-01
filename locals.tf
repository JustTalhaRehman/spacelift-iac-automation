locals {
  # Your organization/product prefix — used in stack names
  product = "my-org"

  # GitHub repository containing your IaC code
  repository = "my-iac-repo"

  # Root Spacelift space path
  parent_space_path = "root/MyOrg"

  # Paths that should be administrative stacks (can manage other stacks)
  administrative_paths = [
    "spacelift/administrative/"
  ]

  # Folders to skip — not every main.tf needs a stack
  ignore_paths = ["main.tf", "**/.terraform/**"]

  # Load account definitions
  accounts = yamldecode(templatefile("configs/accounts.yml", {}))

  # Discover all main.tf files in the repo
  stack_paths_raw = fileset(path.module, "**/main.tf")

  # Strip the /main.tf suffix to get folder paths
  stacks_clean_folders = [
    for file_path in local.stack_paths_raw :
    replace("${file_path}", "/main.tf", "")
  ]

  # Remove .terraform directories (generated, not real stacks)
  stacks_remove_dotdir = compact([
    for item in local.stacks_clean_folders :
    strcontains(item, ".terraform") ? "" : item
  ])

  # Final filtered set
  stacks_clean_folders_filtered = setsubtract(
    local.stacks_remove_dotdir,
    toset(local.ignore_paths)
  )

  # Collect folders that have a dependencies.yml
  dependency_dirs = [
    for s in local.stacks_clean_folders_filtered :
    s if length(fileset("${path.module}/${s}", "dependencies.yml")) > 0
  ]

  # Parse all dependency files into a flat map
  dependencies = {
    for item in flatten([
      for i, f in local.dependency_dirs : [
        for k, v in yamldecode(templatefile("${f}/dependencies.yml", {})) : {
          stack           = format("%s-%s", local.product, replace(f, "/", "-"))
          dependent_stack = format("%s-%s", local.product, replace(k, "/", "-"))
          dependencies    = v
        }
      ]
    ]) : "${item.stack}-${item.dependent_stack}" => item
  }
}
