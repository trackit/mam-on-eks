resource "aws_sns_topic" "mam_sns_topic" {
  name = "${var.project}-sns-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.mam_sns_topic.arn
  protocol  = "email"
  endpoint  = var.email
}
