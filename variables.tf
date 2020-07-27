variable "environment" {
  description = "The resource used by which environment"
  type        = string
  default     = "devops"
}

variable "project" {
  description = "The resource used by which project"
  type        = string
  default     = "billing"
}

variable "service" {
  description = "The resource provide what kind of service"
  type        = string
  default     = "billing"
}

variable "name" {
  description = "The resource identify name"
  type        = string
  default     = "alarm"
}

variable "slack_webhook_url" {
  description = "The URL of Slack webhook"
  type        = string
}

variable "slack_channel" {
  description = "The name of the channel in Slack for notifications"
  type        = string
}

variable "slack_username" {
  description = "The username that will appear on Slack messages"
  type        = string
}

variable "cloudwatch_alarm_config" {
  description = "The cloudwatch alarm configuration"
  type        = object({
    comparison_operator = string
    evaluation_periods  = string
    standard_deviations = string
    metric_name         = string
    namespace           = string
    period              = string
    stat                = string
    currency            = string
  })
  default     = {
    comparison_operator = "GreaterThanUpperThreshold"
    evaluation_periods  = "1"
    standard_deviations = "2"
    metric_name         = "EstimatedCharges"
    namespace           = "AWS/Billing"
    period              = "3600"
    stat                = "Maximum"
    currency            = "USD"   
  }
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to the resources."
  type        = map(string)
  default     = {}
}