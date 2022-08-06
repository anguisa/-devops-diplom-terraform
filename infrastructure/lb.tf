# Целевая группа для балансировщика
resource "yandex_lb_target_group" "tg-lb" {
  name      = "tg-lb1"
  folder_id = local.folder_id

  dynamic "target" {
    # динамически привязываем приватные сети только воркер нод
    for_each = { for key, val in local.k8s_desc:
                 key => val if val["master"] == false }
    content {
      subnet_id = yandex_compute_instance.worker-vm[target.key].network_interface[0].subnet_id
      address = yandex_compute_instance.worker-vm[target.key].network_interface[0].ip_address
    }
  }
}

# Network load balancer
resource "yandex_lb_network_load_balancer" "network-lb" {
  name = "network-lb1"
  folder_id = local.folder_id

  listener {
    name = "listener1"
    port = 8000
    target_port = 80
    protocol = "tcp"
  }

  listener {
    name = "listener2"
    port = 443
    target_port = 443
    protocol = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg-lb.id
    healthcheck {
      name = "http"
      http_options {
        port = 10254
        path = "/healthz"
      }
    }
  }
}