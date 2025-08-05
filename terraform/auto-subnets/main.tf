data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

# A local value is used to create a single map of all subnets to be created.
# Each item in the map contains a global index (for CIDR allocation),
# a local index (for naming), the subnet bits, and the type.
locals {
  subnets_with_indices = flatten([
    for config_idx, config in var.subnets_config : [
      for local_idx in range(config.num_subnets) : {
        type         = config.type
        subnet_bits  = config.subnet_bits
        local_index  = local_idx + 1 # Start local index at 1
        global_index = (config_idx == 0 ? 0 : sum([for k in range(config_idx) : var.subnets_config[k].num_subnets])) + local_idx
      }
    ]
  ])

  subnets_map = {
    for s in local.subnets_with_indices : s.global_index => s
  }
}

resource "aws_subnet" "auto_generated" {
  for_each = local.subnets_map

  vpc_id = data.aws_vpc.selected.id

  # The global index (each.key) is used to ensure each CIDR block is unique.
  cidr_block = cidrsubnet(
    data.aws_vpc.selected.cidr_block,
    each.value.subnet_bits - tonumber(split("/", data.aws_vpc.selected.cidr_block)[1]),
    tonumber(each.key)
  )

  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key) % length(data.aws_availability_zones.available.names)]

  tags = {
    # The local index is used here to meet the naming requirement.
    Name             = "${each.value.type}-subnet-${each.value.local_index}"
    AvailabilityZone = data.aws_availability_zones.available.names[tonumber(each.key) % length(data.aws_availability_zones.available.names)]
    deployment_type  = each.value.type
  }
}