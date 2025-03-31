resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "${var.project}-eks-cloudwatch-agent-role"
  tags = {
    Name        = "${var.project}-eks-cloudwatch-agent-role"
    Environment = var.env
    Owner       = var.owner
    Project     = var.project
  }
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "pods.eks.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.cloudwatch_agent_role.name
}

resource "aws_eks_addon" "amazon_cloudwatch_observability" {

  cluster_name  = var.cluster.name
  addon_name    = "amazon-cloudwatch-observability"

  configuration_values = file("${path.module}/configs/amazon-cloudwatch-observability.json")

  pod_identity_association {
    role_arn = aws_iam_role.cloudwatch_agent_role.arn
    service_account = "cloudwatch-agent"
  }
}

resource "aws_cloudwatch_metric_alarm" "pod_crash_alarm" {
  alarm_name          = "${var.project}-pod-crash-loop-back-off"
  metric_name         = "pod_container_status_waiting_reason_crash_loop_back_off"
  namespace           = "ContainerInsights"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alarm when CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.mam_sns_topic_pod_crash.arn]

  dimensions = {
    ClusterName = var.cluster.name
  }
}
