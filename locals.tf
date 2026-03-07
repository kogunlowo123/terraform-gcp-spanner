locals {
  # Merge common labels with per-instance labels
  instance_labels = {
    for k, v in var.instances : k => merge(var.labels, v.labels)
  }

  # Flatten instance IAM bindings
  instance_iam_members = merge([
    for binding_key, binding in var.instance_iam_bindings : {
      for member in binding.members :
      "${binding_key}/${member}" => {
        instance  = binding.instance
        role      = binding.role
        member    = member
        condition = binding.condition
      }
    }
  ]...)

  # Flatten database IAM bindings
  database_iam_members = merge([
    for binding_key, binding in var.database_iam_bindings : {
      for member in binding.members :
      "${binding_key}/${member}" => {
        instance  = binding.instance
        database  = binding.database
        role      = binding.role
        member    = member
        condition = binding.condition
      }
    }
  ]...)
}
