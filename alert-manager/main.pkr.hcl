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
    "EXPOSE 9093",
    "CMD [ \"--config.file=/opt/coredge/alertmanager/conf/config.yml\", \"--storage.path=/opt/coredge/alertmanager/data\"]",
    "ENTRYPOINT [ \"/opt/coredge/alertmanager/bin/alertmanager\"]"
  ]
}

build {
  name = "Coredge-image"
  sources = [
    "source.docker.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get -y install sudo ca-certificates curl tar",
      "mkdir /opt/coredge",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "curl -SsLf \"https://downloads.bitnami.com/files/stacksmith/alertmanager-0.25.0-5-linux-amd64-debian-11.tar.gz\" -O",
      "tar -zxf alertmanager-0.25.0-5-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2",
      "chmod g+rwX /opt/coredge",
      "ln -sf /opt/coredge/alertmanager/conf /etc/alertmanager",
      "ln -sf /opt/coredge/alertmanager/data /alertmanager",
      "chmod g+rwX /opt/coredge",
      "mkdir -p /opt/coredge/alertmanager/data/ && chmod g+rwX /opt/coredge/alertmanager/data/",
    ]
  }

  post-processor "docker-tag" {
    repository = "coredge/alertmanager-packer"
    tags = ["v1"]
  }
}