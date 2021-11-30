variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default = "wasmcloud"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 1
}

variable "consul_service_name" {
  description = "The consul service name for the hello-world application"
  type        = string
  default     = "wasmcloud-host"
}

variable "consul_service_tags" {
  description = "The consul service name for the hello-world application"
  type        = list(string)
  default = []
}
