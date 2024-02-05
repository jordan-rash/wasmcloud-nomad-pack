job [[ template "job_name" . ]] {
  datacenters = [ [[ range $idx, $dc := .wasmcloud.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  group "nats" {
    network {
      mode = "bridge"
      port "nats" {
        to     = 4222
      }
      port "natshealth" {
        to     = 6003
      }
    }

    service {
      name = "nats"
      port = 4222

      connect {
        sidecar_service {
            tags = [ "nats" ]
        }
      }

      check {
        type     = "http"
        port     = "natshealth"
        name     = "healthz"
        path     = "/"
        interval = "10s"
        timeout  = "3s"
      }
    }

    task "web" {
      driver = "docker"

      config {
        image        = "nats:2.9"
        command      = "-js"
        args         = ["-m", "6003"]
        ports = ["nats","natshealth"]
      }
    }
  }

group "wasmcloud" {
    count = [[ .wasmcloud.count ]]
    network {
      mode = "bridge"

      port "http" {
        static = 4000
        to     = 4000
      }
    }

    service {
      name = "[[ .wasmcloud.consul_service_name ]]"
      tags = [ [[ range $idx, $tag := .wasmcloud.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "nats"
              local_bind_port  = 4222
            }
          }
        }
      }
    }

    task "runtime" {
      driver = "docker"

      env {
          WASMCLOUD_RPC_HOST      = "${NOMAD_UPSTREAM_IP_nats}"
          WASMCLOUD_CTL_HOST      = "${NOMAD_UPSTREAM_IP_nats}"
          WASMCLOUD_PROV_RPC_HOST = "${NOMAD_UPSTREAM_IP_nats}"
          WASMCLOUD_RPC_PORT      = "${NOMAD_UPSTREAM_PORT_nats}"
          WASMCLOUD_CTL_PORT      = "${NOMAD_UPSTREAM_PORT_nats}"
          WASMCLOUD_PROV_RPC_PORT = "${NOMAD_UPSTREAM_PORT_nats}"
         
      }

      config {
        image = "louiaduc/wasmcloud-ubuntu:latest"
      }
    }
  }
}
