# EC2 IAM Role
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "secrets_access" {
  role = aws_iam_role.ec2_ecr_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.secrets_manager_secret_id}*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}


# EC2 Auto Scaling
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [var.security_group_id]
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e

              sudo dnf update -y
              sudo dnf install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              docker --version

              sudo dnf install -y aws-cli jq

              # Fetch secrets from Secrets Manager
              export SECRETS=$(aws secretsmanager get-secret-value \
                --secret-id ${var.secrets_manager_secret_id} \
                --region ${var.region} \
                --query SecretString \
                --output text)

              export DB_PASSWORD=$(echo $SECRETS | jq -r '.mythiqa_db_password')
              export CLERK_SECRET=$(echo $SECRETS | jq -r '.mythiqa_clerk_secret_key')
              export AWS_ACCESS_KEY=$(echo $SECRETS | jq -r '.mythiqa_access_key_id')
              export AWS_SECRET=$(echo $SECRETS | jq -r '.mythiqa_s3_secret_access_key')

              # ECR Login
              aws ecr get-login-password --region ${var.region} \
                | sudo docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
  
              # Pull image
              sudo docker pull ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository_name}:${var.docker_image_tag}

              # Run container with all environment variables
              sudo docker run -d \
                --restart unless-stopped \
                -p ${var.container_port}:${var.container_port} \
                -e SPRING_DATASOURCE_URL="${var.db_jdbc_url}" \
                -e SPRING_DATASOURCE_USERNAME="${var.db_username}" \
                -e SPRING_DATASOURCE_PASSWORD="$DB_PASSWORD" \
                -e CLERK_JWT_ISSUER="${var.clerk_jwt_issuer}" \
                -e CLERK_SECRET_KEY="$CLERK_SECRET" \
                -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY" \
                -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET" \
                -e AWS_REGION="${var.region}" \
                -e AWS_S3_BUCKET="${var.s3_bucket_name}" \
                --name backend \
                ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository_name}:${var.docker_image_tag}
              EOF
    
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-backend"
    }
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-backend-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "EC2"
  health_check_grace_period = 300
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend-instance"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 100
      instance_warmup        = 120
    }
}

/*
# Backend Docker image will go here
# Not tracked by tf state
resource "aws_ecr_repository" "backend" {
  name = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  lifecycle {
    prevent_destroy = true
  }
}
*/
