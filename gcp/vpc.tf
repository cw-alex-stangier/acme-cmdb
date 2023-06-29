module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 7.0"

    project_id   = var.project
    network_name = "${var.academy_prefix}-${var.project_name}-vpc"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "${var.academy_prefix}-${var.project_name}-subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = var.target_region
        }
    ]
}

resource "google_compute_address" "ip_address" {
  name = "${var.academy_prefix}-${var.project_name}-address"
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 5.0"

  name    = "${var.academy_prefix}-${var.project_name}-router"
  project = var.project
  region  = var.target_region
  network = module.vpc.network_name
}

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "~> 1.2"
  project_id = var.project
  region     = var.target_region
  router     = module.cloud_router.name
}

module "serverless-connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  project_id = var.project
  vpc_connectors = [{
    name            = "central-serverless"
    region          = var.target_region
    subnet_name     = module.vpc.subnets[0].name
    host_project_id = var.project
    machine_type    = "e2-micro-4"
    min_instances   = 0
    max_instances   = 3
    max_throughput  = 300
  }]
}