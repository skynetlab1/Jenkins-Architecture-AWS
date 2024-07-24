resource "aws_subnet" "subnet_1" {
  provider = aws.us-east-2

  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Source = "azcoops"
  }
}

resource "aws_subnet" "subnet_1_oregon" {
  provider = aws.us-west-2

  vpc_id            = aws_vpc.vpc_master_us_west_2.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Source = "azcoops"
  }
}

resource "aws_subnet" "subnet_2" {
  provider = aws.us-east-2

  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Source = "azcoops"
  }
}

resource "aws_vpc" "vpc_master" {
  provider = aws.us-east-2

  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "10.0.0.0/16"

  tags = {
    Source = "azcoops"
    Name   = "matts-master-vpc"
  }
}

resource "aws_vpc" "vpc_master_us_west_2" {
  provider = aws.us-west-2

  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "192.168.0.0/16"

  tags = {
    Source = "azcoops"
    Name   = "matts-worker-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  provider = aws.us-east-2

  vpc_id = aws_vpc.vpc_master.id

  tags = {
    Source = "azcoops"
  }
}

resource "aws_internet_gateway" "igw-oregon" {
  provider = aws.us-west-2

  vpc_id = aws_vpc.vpc_master_us_west_2.id

  tags = {
    Source = "azcoops"
  }
}

resource "aws_vpc_peering_connection" "useast2-uswest2" {
  provider = aws.us-east-2

  vpc_id      = aws_vpc.vpc_master.id
  peer_vpc_id = aws_vpc.vpc_master_us_west_2.id
  peer_region = var.region-worker

  tags = {
    Source = "azcoops"
  }
}

resource "aws_route_table" "internet_route" {
  provider = aws.us-east-2

  vpc_id = aws_vpc.vpc_master.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Source = "azcoops"
    Name   = "Master-Region-RT"
  }
}

resource "aws_main_route_table_association" "aws_main_route_table_association_d71db21a" {
  provider = aws.us-east-2

  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

resource "aws_route_table" "internet_route_oregon" {
  provider = aws.us-west-2

  vpc_id = aws_vpc.vpc_master_us_west_2.id

  route {
    gateway_id = aws_internet_gateway.igw-oregon.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Source = "azcoops"
    Name   = "Worker-Region-RT"
  }
}

resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider = aws.us-west-2

  vpc_id         = aws_vpc.vpc_master_us_west_2.id
  route_table_id = aws_route_table.internet_route_oregon.id
}

resource "aws_security_group" "jenkins-sg" {
  provider = aws.us-east-2

  vpc_id      = aws_vpc.vpc_master.id
  name        = "jenkins-sg"
  description = "Allow TCP/8080 & TCP/22"

  tags = {
    Source = "azcoops"
  }
}

resource "aws_security_group" "jenkins-sg-oregon" {
  provider = aws.us-west-2

  vpc_id      = aws_vpc.vpc_master_us_west_2.id
  name        = "jenkins-sg-oregon"
  description = "Allow TCP/8080 & TCP/22"

  tags = {
    Source = "azcoops"
  }
}

resource "aws_security_group" "lb-sg" {
  provider = aws.us-east-2

  vpc_id      = aws_vpc.vpc_master.id
  name        = "lb-sg"
  description = "Allow 443 and traffic to Jenkins SG"

  tags = {
    Source = "azcoops"
  }
}

resource "aws_security_group_rule" "aws_security_group_rule-6a963203" {
  provider = aws.us-east-2

  type              = "ingress"
  to_port           = 0
  security_group_id = aws_security_group.jenkins-sg.id
  protocol          = "-1"
  from_port         = 0
  description       = "Allow traffic from us-west-2"

  cidr_blocks = [
    "192.168.1.0/24",
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-a5db6d6d" {
  provider = aws.us-east-2

  type              = "ingress"
  to_port           = var.webserver-port
  security_group_id = aws_security_group.jenkins-sg.id
  protocol          = "tcp"
  from_port         = var.webserver-port
  description       = "Allow anyone on port 8080"
}

resource "aws_security_group_rule" "aws_security_group_rule-bba6e6bc" {
  provider = aws.us-east-2

  type              = "ingress"
  to_port           = 22
  security_group_id = aws_security_group.jenkins-sg.id
  protocol          = "tcp"
  from_port         = 22
  description       = "Allow 22 from our public IP"

  cidr_blocks = [
    var.external_ip,
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-bcdf5fec" {
  provider = aws.us-west-2

  type              = "ingress"
  to_port           = 22
  security_group_id = aws_security_group.jenkins-sg-oregon.id
  protocol          = "tcp"
  from_port         = 22
  description       = "Allow 22 from our public IP"

  cidr_blocks = [
    var.external_ip,
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-becf1315" {
  provider = aws.us-east-2

  type              = "egress"
  to_port           = 0
  security_group_id = aws_security_group.lb-sg.id
  protocol          = "-1"
  from_port         = 0
  description       = "Allow all from anywhere"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-c0f59b71" {
  provider = aws.us-west-2

  type              = "egress"
  to_port           = 0
  security_group_id = aws_security_group.jenkins-sg-oregon.id
  protocol          = "-1"
  from_port         = 0
  description       = "Allow all from anywhere"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-cd816426" {
  provider = aws.us-east-2

  type              = "ingress"
  to_port           = 80
  security_group_id = aws_security_group.lb-sg.id
  protocol          = "tcp"
  from_port         = 80
  description       = "Allow 80 from anywhere"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-d771cb77" {
  provider = aws.us-west-2

  type              = "ingress"
  to_port           = 0
  security_group_id = aws_security_group.jenkins-sg-oregon.id
  protocol          = "-1"
  from_port         = 0
  description       = "Allow traffic from us-east-2"

  cidr_blocks = [
    "10.0.1.0/24",
  ]
}

resource "aws_security_group_rule" "aws_security_group_rule-dc61e49a" {
  provider = aws.us-east-2

  type              = "egress"
  to_port           = 0
  security_group_id = aws_security_group.jenkins-sg.id
  protocol          = "-1"
  from_port         = 0
  description       = "Allow all from anywhere"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "ingress_443" {
  provider = aws.us-east-2

  type              = "ingress"
  to_port           = 443
  security_group_id = aws_security_group.lb-sg.id
  protocol          = "tcp"
  from_port         = 443
  description       = "Allow 443 from anywhere"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_key_pair" "master-key" {
  provider = aws.us-east-2

  public_key = var.master_pub_key

  tags = {
    Source = "azcoops"
  }
}

resource "aws_key_pair" "worker-key" {
  provider = aws.us-west-2

  public_key = var.worker_pub_key

  tags = {
    Source = "azcoops"
  }
}

resource "aws_instance" "jenkins-master" {
  provider = aws.us-east-2

  subnet_id                   = aws_subnet.subnet_1.id
  key_name                    = aws_key_pair.master-key.key_name
  instance_type               = "t3.micro"
  availability_zone           = "us-east-2a"
  associate_public_ip_address = true
  ami                         = var.ami

  depends_on = [
    aws_main_route_table_association.set-worker-default-rt-assoc,
  ]

  tags = {
    Source = "azcoops"
    Name   = "jenkins_master_tf"
  }

  vpc_security_group_ids = [
    aws_security_group.jenkins-sg.id,
  ]
}

resource "aws_instance" "jenkins-worker-oregon" {
  provider = aws.us-west-2

  subnet_id                   = aws_subnet.subnet_1_oregon.id
  key_name                    = aws_key_pair.worker-key.key_name
  instance_type               = "t3.micro"
  count                       = var.workers-count
  availability_zone           = "us-west-2a"
  associate_public_ip_address = true
  ami                         = var.ami

  depends_on = [
    aws_main_route_table_association.set-worker-default-rt-assoc,
    aws_instance.jenkins-master,
  ]

  tags = {
    Source = "azcoops"
    Name   = join("_", ["jenkins_worker_tf", count.index + 1])
  }

  vpc_security_group_ids = [
    aws_security_group.jenkins-sg-oregon.id,
  ]
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.us-east-2

  zone_id = var.zone-id
  type    = "A"
  name    = "jenkins.rtodorov-devops"
}

resource "aws_route53_record" "jenkins" {
  provider = aws.us-east-2

  zone_id = var.zone-id
  type    = "A"
  name    = "jenkins.rtodorov-devops"

  alias {
    zone_id                = aws_lb.application-lb.zone_id
    name                   = aws_lb.application-lb.dns_name
    evaluate_target_health = true
  }
}

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider = aws.us-west-2

  vpc_peering_connection_id = aws_vpc_peering_connection.useast2-uswest2.id

  tags = {
    Source = "azcoops"
  }
}

resource "aws_lb" "application-lb" {
  provider = aws.us-east-2

  name               = "jenkins-lb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [
    aws_security_group.lb-sg.id,
  ]

  subnets = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id,
  ]

  tags = {
    Source = "azcoops"
    Name   = "Jenkins-LB"
  }
}

resource "aws_lb_target_group" "app-lb-tg" {
  provider = aws.us-east-2

  vpc_id      = aws_vpc.vpc_master.id
  target_type = "instance"
  protocol    = "HTTP"
  port        = var.webserver-port
  name        = "app-lb-tg"

  health_check {
    protocol = "HTTP"
    port     = var.webserver-port
    path     = "/"
    matcher  = "200-299"
    interval = 10
    enabled  = true
  }

  tags = {
    Source = "azcoops"
    Name   = "jenkins-target-group"
  }
}

resource "aws_lb_listener" "aws_lb_listener_117174a9" {
  provider = aws.us-east-2

  port              = 80
  load_balancer_arn = aws_lb.application-lb.arn

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.app-lb-tg.id
    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      port        = "443"
    }
  }
}

resource "aws_lb_listener" "jenkins-listener-https" {
  provider = aws.us-east-2

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  protocol          = "HTTPS"
  port              = 443
  load_balancer_arn = aws_lb.application-lb.arn
  certificate_arn   = aws_acm_certificate.jenkins-lb-https.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins-master-attach" {
  provider = aws.us-east-2

  target_id        = aws_instance.jenkins-master.id
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  port             = var.webserver-port
}

resource "aws_acm_certificate" "jenkins-lb-https" {
  provider = aws.us-east-2

  validation_method = "DNS"
  domain_name       = "jenkins.rtodorov-devops"

  tags = {
    Source = "azcoops"
    Name   = "Jenkins-ACM"
  }
}

resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east-2

  for_each        = aws_route53_record.cert_validation
  certificate_arn = aws_acm_certificate.jenkins-lb-https.arn

  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn,
  ]
}

