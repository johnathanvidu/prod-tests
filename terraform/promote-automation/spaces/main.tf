locals {
  environments = {
    dev     = "dev"
    staging = "stage"
    prod    = "prod"
  }
  colors = ["darkGray", "mediumGray", "darkBlue", "mediumBlue", "blueGrey", "darkGreen", "frogGreen", "pinkPurple", "pinkBrown", "lightGrey", "pinkRed", "midnightBlue"]
}

resource "random_integer" "color_selector" {
  for_each = local.environments

  # The minimum value for the random integer (0-indexed)
  min = 0
  # The maximum value for the random integer (exclusive, so length - 1)
  max = length(local.colors) - 1

  # 'keepers' ensures that if these values change, the random number is re-generated.
  # This ties the randomness to the specific resource instance.
  keepers = {
    resource_key = each.key
    prefix       = var.project_name
  }
}

resource "torque_space" "new_space" {
  for_each   = local.environments

  space_name = "${var.project_name}-${each.value}"
  color      = element(local.colors, random_integer.color_selector[each.key].result)
  icon       = var.icon
}

resource "torque_agent_space_association" "agent_association" {
  for_each        = local.environments

  space_name      = torque_space.new_space[each.key].space_name
  agent_name      = var.agent_name
  service_account = "${var.project_name}-${each.key}-sa"
  namespace       = "${var.project_name}-${each.key}"
}

resource "torque_ado_server_repository_space_association" "common-assets" {
  for_each        = local.environments

  space_name      = torque_space.new_space[each.key].space_name
  repository_name = "Infrastructure"
  repository_url  = "http://192.168.42.224/DefaultCollection/Vido/_git/Vido"
  branch            = "main"
  credential_name   = "ado"
  auto_register_eac = false
  use_all_agents    = true
}

resource "torque_ado_server_repository_space_association" "environments_repo" {
  for_each        = local.environments

  space_name      = torque_space.new_space[each.key].space_name
  repository_name = "${each.key}"
  repository_url  = "http://192.168.42.224/DefaultCollection/Vido/_git/${var.project_name}-${each.value}"
  branch            = "main"
  credential_name   = "ado"
  auto_register_eac = true
  use_all_agents    = true
}

resource "torque_space_parameter" "aws_account_id_param" {
  for_each    = local.environments

  space_name  = torque_space.new_space[each.key].space_name
  name        = "aws_account_id"
  value       = var.aws_accounts[each.value].account_id
  sensitive   = false
  description = "aws account id"
}

resource "torque_space_parameter" "aws_account_name_param" {
  for_each    = local.environments

  space_name  = torque_space.new_space[each.key].space_name
  name        = "aws_account_name"
  value       = var.aws_accounts[each.value].account_name
  sensitive   = false
  description = "aws account name"
}