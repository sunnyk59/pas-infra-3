variable "namespace_name" {
  description = "Name of the Kubernetes namespace for the hospital"
  type        = string
}

variable "environment" {
  description = "Deployment environment (tran, prod)"
  type        = string
}

variable "hospital_name" {
  description = "Hospital name for the namespace"
  type        = string
}
