# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
  routing_mode            = var.routing_mode
}

# Subnets
resource "google_compute_subnetwork" "subnets" {
  for_each                 = var.subnets
  name                     = each.key
  network                  = google_compute_network.vpc.id
  project                  = var.project_id
  region                   = each.value.region
  ip_cidr_range            = each.value.cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Cloud Router
resource "google_compute_router" "router" {
  for_each = var.cloud_nat_configs
  name     = "${var.network_name}-${each.key}-router"
  project  = var.project_id
  region   = each.key
  network  = google_compute_network.vpc.id
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  for_each = var.cloud_nat_configs
  name     = "${var.network_name}-${each.key}-nat"
  project  = var.project_id
  router   = google_compute_router.router[each.key].name
  region   = each.key

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall Rules
resource "google_compute_firewall" "rules" {
  for_each      = var.firewall_rules
  name          = each.key
  project       = var.project_id
  network       = google_compute_network.vpc.id
  direction     = each.value.direction
  priority      = lookup(each.value, "priority", 1000)
  source_ranges = lookup(each.value, "source_ranges", null)
  target_tags   = lookup(each.value, "target_tags", null)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }
}
