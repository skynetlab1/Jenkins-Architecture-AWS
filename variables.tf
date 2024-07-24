variable "ami" {
  type    = string
  default = "rtodorov-ami"
}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "master_pub_key" {
  type    = string
  default = "rtodorov key"
}

variable "region-master" {
  type    = string
  default = "us-east-2"
}

variable "region-worker" {
  type    = string
  default = "us-west-2"
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
  default = {
    archuuid = "7563f072-b05f-4bc2-b9f2-f6d061b6cda8"
    env      = "Development"
  }
}

variable "webserver-port" {
  type    = string
  default = "8080"
}

variable "worker_pub_key" {
  type    = string
  default = "rtodorov key"
}

variable "workers-count" {
  type    = number
  default = 1
}

variable "zone-id" {
  type    = string
  default = "rtodorov-devops"
}

