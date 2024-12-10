output "pem_key" {
  value     = module.key_pair.pem_key
  sensitive = true
}
