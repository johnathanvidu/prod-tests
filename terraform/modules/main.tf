module "module1" {
    source = "./module1"
}

module "module2" {
    source = "./module2"
}

resource "time_static" "current_time" { }

output "current_time" {
    value = time_static.current_time.rfc3339
}

output "module1_time" {
    value = module.module1.current_time
}

output "module2_time" {
    value = module.module2.current_time
}