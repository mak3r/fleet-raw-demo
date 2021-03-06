resource "aws_key_pair" "ssh_key_pair" {
  key_name_prefix = "${var.prefix}-fleet-raw-demo-"
  public_key      = file("${var.ssh_key_file_name}.pub")
}

# Security group to allow all traffic
resource "aws_security_group" "sg_allowall" {
  name        = "${var.prefix}-fleet-raw-demo-allowall"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu_vms" {
  count         = var.amd_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.xlarge"

  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.sg_allowall.name]

  root_block_device {
    volume_size = 80
  }

  tags = {
    Name = "${var.prefix}-fleet-raw-demo-ubuntu"
  }
}

resource "aws_instance" "arm_vms" {
  count         = var.arm_count
  ami           = data.aws_ami.arm.id
  instance_type = "a1.medium"

  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.sg_allowall.name]

  tags = {
    Name = "${var.prefix}-fleet-raw-demo-arm"
  }
}

resource "aws_instance" "gpu_vms" {
  count         = var.demo_gpu ? var.gpu_count : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "p4d.24xlarge"

  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.sg_allowall.name]

  tags = {
    Name = "${var.prefix}-fleet-raw-demo-gpu"
    demo = "NVIDIA MIG"
  }
}