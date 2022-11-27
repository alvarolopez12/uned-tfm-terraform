variable "backend_address_pool_name" {
  default = "myBackendPool"
}

variable "frontend_port_name" {
  default = "myFrontendPort"
}

variable "frontend_ip_configuration_name" {
  default = "myAGIPConfig"
}

variable "http_setting_name" {
  default = "myHTTPsetting"
}

variable "listener_name" {
  default = "myListener"
}

variable "listener_name2" {
  default = "myListener2"
}
variable "request_routing_rule_name" {
  default = "myRoutingRule"
}

variable "request_routing_rule_name2" {
  default = "myRoutingRule2"
}

variable "redirect_configuration_name" {
  default = "myRedirectConfig"
}