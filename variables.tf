variable "environment" {
  description = "Name of the environment"
  default     = "dev"
}

variable "location" {
  description = "Location of the deployment"
  default     = "East Asia"
}

variable "tagversion" {
  description = "Tag version of the current deployment"
  default     = "1"
}

variable "sqlserver-admin-password" {
  default = "quiz*123"
}