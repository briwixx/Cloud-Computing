output "sql_connection_string" {
  value = module.database.sql_connection_string
}

output "rg_name"{
    value = module.resource_group.name
}

output "server_name"{
    value = module.database.server_name
}

output "function_url" {
  value = module.counter_function.function_url
}

output "static_website_url" {
  value = module.static_website.static_website_url
}
