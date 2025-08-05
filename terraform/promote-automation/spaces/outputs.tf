output "space_names" {
    value = [for s in torque_space.new_space: s.space_name]
}