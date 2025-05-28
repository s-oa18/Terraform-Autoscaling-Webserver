#Create autoscaling group
resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
  name = "apache-asg"
  max_size = 5
  min_size = 2
  health_check_type = "ELB"
  termination_policies = ["OldestInstance"]
  launch_template {
    id = aws_launch_template.apache_lt.id
    version = "$Latest"
  }

  target_group_arns = [ aws_alb_target_group.tg.arn ]

}

#Create scaleout policy
resource "aws_autoscaling_policy" "apache_policy_up" {
  name = "apache_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name

}

#Create scaleup alarm
resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_up" {
  alarm_name = "apache_cpu_alarm_up"
  threshold = "60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  period = "120"
  metric_name = "CPUUTILIZATION"
  statistic = "Average"
  namespace = "AWS/EC2"

  dimensions = {
    autoscalingGroupName = aws_autoscaling_group.asg.name 

  }

  alarm_description = "This alarm monitors asg cpu utilization"
  alarm_actions = [aws_autoscaling_policy.apache_policy_up.arn]
}


#Create scalein policy
resource "aws_autoscaling_policy" "apache_policy_down" {
  name = "apache_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name

}

#Create scaledown alarm
resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_down" {
  alarm_name = "apache_cpu_alarm_down"
  threshold = "10"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  period = "120"
  metric_name = "CPUUTILIZATION"
  statistic = "Average"
  namespace = "AWS/EC2"

  dimensions = {
    autoscalingGroupName = aws_autoscaling_group.asg.name 

  }

  alarm_description = "This alarm monitors asg cpu utilization"
  alarm_actions = [aws_autoscaling_policy.apache_policy_down.arn]
}