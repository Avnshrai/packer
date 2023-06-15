packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "siddharth387/coredge:74-f9e1f58"
  commit = true
  changes = [
    "EXPOSE 80",
    "CMD [\"/usr/sbin/nginx\", \"-g\", \"daemon off;\"]",
    "ENTRYPOINT [\"\"]",
    ]
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
      "apt-get update",
      "apt-get install -y nginx",
      "adduser --disabled-password --gecos \"\" myuser",
      "chown -R myuser /var/www/html",  # Adjust the directory as needed
      "usermod -aG sudo myuser",         # Optionally add the user to the sudo group
      "echo 'myuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers",  # Optionally allow sudo without password
      "sed -i 's/^root:/myuser:/g' /etc/passwd",  # Set myuser as the default user
    ]
  }

  post-processor "docker-tag" {
  repository = "coredge/ubuntu-packer"
  tags = ["v1"]
  }
}


