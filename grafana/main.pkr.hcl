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
    "EXPOSE 3000",
    "CMD [ \"/opt/coredge/scripts/grafana/run.sh\" ]",
    "ENTRYPOINT [ \"/opt/coredge/scripts/grafana/entrypoint.sh\"]"
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
      "sudo adduser --disabled-password --gecos \"\" grafana",
      "sudo usermod -aG sudo grafana",
      "apt-get -y install sudo ca-certificates curl tar libfontconfig",
      "mkdir /opt/coredge",
      "mkdir -p /tmp/coredge/pkg/cache/ && cd /tmp/coredge/pkg/cache/",
      "curl -SsLf \"https://downloads.bitnami.com/files/stacksmith/grafana-9.5.3-0-linux-amd64-debian-11.tar.gz\" -O",
      "tar -zxf grafana-9.5.3-0-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2",
      "chmod g+rwX /opt/coredge",
      "mkdir -p /opt/coredge/scripts/grafana",
      "mkdir -p /opt/coredge/grafana/conf",
      "touch /opt/coredge/grafana/conf/grafana.ini",
      "mkdir -p /opt/coredge/grafana/data",
      "mkdir -p /opt/coredge/grafana/logs",
      "mkdir -p /opt/coredge/grafana/tmp",
    ]
  }
  provisioner "file" {
    source      = "rootfs/"
    destination = "opt/"
  }
  provisioner "file" {
    source  = "prebuildfs/opt/"
    destination = "opt/"
  }
  provisioner "shell" {
    inline = [
      "chmod -R +x /opt/*"
    ]
  }
  post-processor "docker-tag" {
    repository = "coredge/grafana-packer"
    tags = ["v1"]
  }
}