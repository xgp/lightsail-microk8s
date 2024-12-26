provider "aws" {
  region = "us-east-1"
}

resource "aws_lightsail_instance" "microk8s" {
  count              = var.instance_count
  name               = "microk8s-${count.index}"
  availability_zone  = "us-east-1a"
  blueprint_id       = "ubuntu_24_04"
  # bundle_id          = "2xlarge_3_0"
  bundle_id          = "nano_2_0"
  key_pair_name      = aws_lightsail_key_pair.microk8s_key_pair.name
  user_data          = templatefile("setup_microk8s.sh", {
    instance_index    = count.index,
    control_plane_ip  = aws_lightsail_instance.microk8s[0].private_ip_address
  })
  private_networking = true

  add_on {
    name          = "AutoSnapshot"
    status        = "Enabled"
    snapshot_time = "00:00"
  }

  tags = {
    Environment = "MicroK8s"
  }
}

resource "aws_lightsail_key_pair" "microk8s_key_pair" {
  name = "microk8s-key-pair"
}

# Lightsail Firewall Rules (Networking)
resource "aws_lightsail_instance_public_ports" "microk8s_ports" {
  count      = var.instance_count
  instance_name = aws_lightsail_instance.microk8s[count.index].name

  # Public-facing ports (SSH and Kubernetes API)
  port_info {
    from_port = 22    # SSH
    to_port   = 22
    protocol  = "tcp"
  }

  port_info {
    from_port = 16443 # Kubernetes API
    to_port   = 16443
    protocol  = "tcp"
  }

  # Private-facing ports (MicroK8s HA cluster communication)
  port_info {
    from_port = 19001 # dqlite
    to_port   = 19001
    protocol  = "tcp"
  }

  port_info {
    from_port = 25000 # Worker communication
    to_port   = 25000
    protocol  = "tcp"
  }

  port_info {
    from_port = 10250 # Kubelet API
    to_port   = 10250
    protocol  = "tcp"
  }

  port_info {
    from_port = 12379 # Etcd
    to_port   = 12379
    protocol  = "tcp"
  }

  port_info {
    from_port = 10255 # Read-only Kubelet API
    to_port   = 10255
    protocol  = "tcp"
  }
}

output "instance_public_ips" {
  value = aws_lightsail_instance.microk8s[*].public_ip_address
}

output "instance_private_ips" {
  value = aws_lightsail_instance.microk8s[*].private_ip_address
}

output "control_plane_ip" {
  value = aws_lightsail_instance.microk8s[0].private_ip_address
}
