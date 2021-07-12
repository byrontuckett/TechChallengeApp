variable "location" {
  type        = string
  description = "azure region where the resource will be created"
  default     = "westus2"
}
variable "resourceGroupName" {
  type        = string
  description = "Name of resource group"
  default     = "rg-techchallengeapp"
}
variable "databaseName" {
  type        = string
  description = "PostreSQL database name"
  default     = "tca_dev"
}
variable "sqlServerName" {
  type    = string
  default = "tcasql202106"
}

variable "dbUser" {
  type    = string
  default = "sparticus"
}

variable "dbPassword" {
  type        = string
  description = "provide a secure password for PostreSQL"
}
