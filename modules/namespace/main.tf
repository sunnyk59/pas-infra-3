

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace_name

    labels = {
      environment = var.environment
      hospital    = var.hospital_name
    }
  }
}
