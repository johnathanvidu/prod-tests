resource "time_static" "current_time" { }

output "current_time" {
    value = time_static.current_time.rfc3339
}