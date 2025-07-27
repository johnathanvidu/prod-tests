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
    prefix       = var.name
  }
}

resource "torque_space" "new_space" {
    for_each = local.environments

    space_name = "${var.name}-${each.value}"
    color      = element(local.colors, random_integer.color_selector[each.key].result)
    icon       = var.icon
}