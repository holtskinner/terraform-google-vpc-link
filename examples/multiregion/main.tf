# Copyright 2020 Open Infrastructure Services, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "num_instances" {
  description = "Set to 0 to reduce costs when not actively developing."
  type        = number
  default     = 1
}

variable "preemptible" {
  description = "Allows instance to be preempted. This defaults to false. See https://cloud.google.com/compute/docs/instances/preemptible"
  type        = bool
  default     = true
}

locals {
  project_id = "multinic-networks-18d1"

  nic0_network = "main"
  nic1_network = "transit"
}

## NOTE on cidr ranges
# nic0_cidrs means the CIDR ranges for each traffic routes via (egress) nic0.
# nic0 is "eastbound" toward the main Shared VPC.
#
# nic1_cidrs means the CIDR ranges for each traffic routes via (egress) nic1.
# nic1 is "westbound" toward the Transit VPC

# Manage the regional MIG formation
module "multinic-us-west1" {
  source = "../../modules/52_regional_multinic"

  num_instances = var.num_instances
  preemptible   = var.preemptible

  project_id  = local.project_id
  region      = "us-west1"

  nic0_network = local.nic0_network
  nic0_project = local.project_id
  # Subnet nic0 is attached to.
  nic0_subnet  = "main-bridge"
  # Eastbound cidrs close to this region are routed through this multinic.
  nic0_cidrs   = ["10.32.0.0/20", "10.33.0.0/20"]

  nic1_network = local.nic1_network
  nic1_project = local.project_id
  # Subnet nic1 is attached to.
  nic1_subnet  = "transit-bridge"
  # Westbound cidrs close to this region are routed through this multinic.
  nic1_cidrs   = ["10.36.0.0/20", "10.37.0.0/20"]

  service_account_email = "multinic@${local.project_id}.iam.gserviceaccount.com"
}

# Manage the regional MIG formation
module "multinic-us-west2" {
  source = "../../modules/52_regional_multinic"

  num_instances = var.num_instances
  preemptible   = var.preemptible

  project_id  = local.project_id
  region      = "us-west2"

  nic0_network = local.nic0_network
  nic0_project = local.project_id
  # Subnet nic0 is attached to.
  nic0_subnet  = "main-bridge2"
  # Eastbound cidrs close to this region are routed through this multinic.
  nic0_cidrs   = ["10.34.0.0/20", "10.40.0.0/20"]

  nic1_network = local.nic1_network
  nic1_project = local.project_id
  # Subnet nic1 is attached to.
  nic1_subnet  = "transit-bridge2"
  # Westbound cidrs close to this region are routed through this multinic.
  nic1_cidrs   = ["10.38.0.0/20", "10.41.0.0/20"]

  service_account_email = "multinic@${local.project_id}.iam.gserviceaccount.com"
}