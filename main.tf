data "aws_caller_identity" "current" {}
data "aws_iam_account_alias" "current" {}

module "label" {
  source      = "git::https://github.com/getamis/terraform-null-label.git?ref=v1.0.0"
  environment = var.environment
  project     = var.project
  name        = var.name
  service     = var.service
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name = module.label.id

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username

  tags = merge(
    module.label.tags,
    var.extra_tags,
    tomap({
      "Name" = module.label.id,
      "Role" = "notification",
    })
  )
}

resource "aws_cloudwatch_metric_alarm" "account_billing_alarm_to_existing_sns" {
  alarm_name          = "${data.aws_iam_account_alias.current.account_alias} ${var.project} ${var.name}"
  alarm_description   = "Billing anomaly detection alarm for account ${data.aws_caller_identity.current.account_id}"
  comparison_operator = var.cloudwatch_alarm_config["comparison_operator"]
  evaluation_periods  = var.cloudwatch_alarm_config["evaluation_periods"]
  datapoints_to_alarm = var.cloudwatch_alarm_config["datapoints_to_alarm"]
  alarm_actions       = [module.notify_slack.this_slack_topic_arn]
  treat_missing_data  = var.cloudwatch_alarm_config["treat_missing_data"]
  threshold_metric_id = "anomalous_cost"

  metric_query {
    id          = "anomalous_cost"
    return_data = true
    expression  = "ANOMALY_DETECTION_BAND(cost, ${var.cloudwatch_alarm_config["standard_deviations"]})"
    label       = "EstimatedCharges (Expected)"
  }

  metric_query {
    id          = "cost"
    return_data = true
    metric {
      metric_name = var.cloudwatch_alarm_config["metric_name"]
      namespace   = var.cloudwatch_alarm_config["namespace"]
      period      = var.cloudwatch_alarm_config["period"]
      stat        = var.cloudwatch_alarm_config["stat"]

      dimensions = {
        Currency      = var.cloudwatch_alarm_config["currency"]
        LinkedAccount = data.aws_caller_identity.current.account_id
      }
    }
  }

  tags = merge(
    module.label.tags,
    var.extra_tags,
    tomap({
      "Name" = module.label.id,
      "Role" = "alarm",
    })
  )
}
