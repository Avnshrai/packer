packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:focal"
  commit = true
}

variable "image_name" {
  type    = string
  default = "coredge-base-image-v22"
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "DEBIAN_FRONTEND=noninteractive apt-get update",
      "echo -e \"\n\" > /etc/issue"  # Remove the Ubuntu version information and replace it with a new lines
    ]
  }

  provisioner "file" {
    source      = "banner.txt"
    destination = "/etc/motd"
  }
  #running commands inside container
  provisioner "shell" {
    inline = [
      "echo '[ ! -z \"$TERM\" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' >> /etc/bash.bashrc",
    ]
  }
  post-processor "docker-tag" {
  repository = "coredge/ubuntu-packer"
  tags = ["v1"]
  }
}