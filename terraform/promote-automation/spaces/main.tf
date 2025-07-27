resource "torque_space" "new_space" {
    count = 3
    space_name = "${var.name}-${count.index}"
    color      = var.color
    icon       = var.icon
}