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
    "EXPOSE 9090",
    "CMD [ \"--config.file=/opt/coredge/prometheus/conf/prometheus.yml\", \"--storage.tsdb.path=/opt/coredge/prometheus/data\", \"--web.console.libraries=/opt/coredge/prometheus/conf/console_libraries\", \"--web.console.templates=/opt/coredge/prometheus/conf/consoles\" ]",
    "ENTRYPOINT [ \"/opt/coredge/prometheus/bin/prometheus\"]"
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
      "curl -SsLf \"https://downloads.bitnami.com/files/stacksmith/prometheus-2.44.0-1-linux-amd64-debian-11.tar.gz\" -O",
      "tar -zxf prometheus-2.44.0-1-linux-amd64-debian-11.tar.gz -C /opt/coredge --strip-components=2",
      "chmod g+rwX /opt/coredge",
      "ln -sf /opt/coredge/prometheus/conf /etc/prometheus",
      "ln -sf /opt/coredge/prometheus/data /prometheus",
      "chown -R 1001:1001 /opt/coredge/prometheus",
      "mkdir -p /opt/coredge/prometheus/data/ && chmod g+rwX /opt/coredge/prometheus/data/",
      "",
    ]
  }

  post-processor "docker-tag" {
    repository = "coredge/prometheus-packer"
    tags = ["v1"]
  }
}