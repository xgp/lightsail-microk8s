variable "instance_count" {
  description = "Number of Lightsail instances for the MicroK8s cluster"
  default     = 3
}

# bundle_id          = "2xlarge_3_0"
variable "bundle_id" {
  description = "AWS Lightsail bundle ID to use for machine sizing"
  default     = "nano_2_0"
}