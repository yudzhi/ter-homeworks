# ============================================
# ДИНАМИЧЕСКАЯ ГРУППА БЕЗОПАСНОСТИ
# Правила автоматически обновляются в зависимости от режима
# ============================================

locals {
  # Получаем CIDR из созданного ресурса подсети
  # subnet_cidr = yandex_vpc_subnet.develop.v4_cidr_blocks

  # Базовые правила, которые нужны всегда
  ingress_rules_always = [
    # HTTP доступ (всегда нужен для веб-серверов)
    {
      protocol       = "TCP"
      description    = "HTTP доступ (веб-серверы)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 80
    },
    # HTTPS доступ (всегда нужен для веб-серверов)
    {
      protocol       = "TCP"
      description    = "HTTPS доступ (веб-серверы)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    }
  ]

  # Правила для SSH в зависимости от режима
  ingress_rules_ssh = var.enable_nat_for_vms ? [
    # Режим с NAT (ВМ видны из интернета)
    {
      protocol       = "TCP"
      description    = "SSH доступ из интернета (прямой)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    }
    ] : [
    # Режим без NAT (ВМ скрыты, доступ через bastion)
    {
      protocol       = "TCP"
      description    = "SSH доступ из приватной подсети (через bastion)"
      v4_cidr_blocks = yandex_vpc_subnet.develop.v4_cidr_blocks
      port           = 22
    }
  ]

  # Правила для bastion (если он включён)
  ingress_rules_bastion = var.bastion.enable ? [
    {
      protocol       = "TCP"
      description    = "SSH доступ для bastion (публичный)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    }
  ] : []

  # Финальный набор правил
  ingress_rules = concat(
    local.ingress_rules_always, # HTTP, HTTPS
    local.ingress_rules_ssh,    # SSH (зависит от режима)
    local.ingress_rules_bastion # SSH для bastion (если включён)
  )
}

# --------------------------------------------
# ГРУППА БЕЗОПАСНОСТИ С ДИНАМИЧЕСКИМИ ПРАВИЛАМИ
# --------------------------------------------

resource "yandex_vpc_security_group" "example" {
  name       = var.security_group_name
  network_id = yandex_vpc_network.develop.id
  folder_id  = var.folder_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      protocol       = ingress.value.protocol
      description    = ingress.value.description
      port           = lookup(ingress.value, "port", null)
      from_port      = lookup(ingress.value, "from_port", null)
      to_port        = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks = ingress.value.v4_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      protocol       = egress.value.protocol
      description    = egress.value.description
      port           = lookup(egress.value, "port", null)
      from_port      = lookup(egress.value, "from_port", null)
      to_port        = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = egress.value.v4_cidr_blocks
    }
  }
}

