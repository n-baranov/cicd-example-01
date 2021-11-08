output "configmap" {
  value = data.kubernetes_config_map.aws_auth.*
}
