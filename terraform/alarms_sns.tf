resource "aws_sns_topic" "mam_sns_topic_database" {
  name = "${var.project}-sns-topic-database"
}

resource "aws_sns_topic_subscription" "email_subscription_database" {
  topic_arn = aws_sns_topic.mam_sns_topic_database.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_sns_topic" "mam_sns_topic_pod_crash" {
  name = "${var.project}-sns-topic-pod-crash"
}

resource "aws_sns_topic_subscription" "email_subscription_pod_crash" {
  topic_arn = aws_sns_topic.mam_sns_topic_pod_crash.arn
  protocol  = "email"
  endpoint  = var.email
}
