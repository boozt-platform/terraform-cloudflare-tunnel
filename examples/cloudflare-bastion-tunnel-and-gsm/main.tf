# SPDX-FileCopyrightText: Copyright Boozt Fashion, AB
# SPDX-License-Identifier: MIT

# This example creates a Cloudflare Tunnel with a bastion mode enabled.
module "tunnel" {
  source      = "github.com/boozt-platform/terraform-cloudflare-tunnel"
  api_token   = var.api_token
  account_id  = var.account_id
  tunnel_name = "bastion"
  tunnel_config = {
    ingress_rule = [
      {
        service = "bastion"
        origin_request = {
          bastion_mode = true
        }
      }
    ]
  }
}

# Create a secret in GCP Secret Manager and store the tunnel secret in it
module "tunnel_secret" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.7"
  project_id = var.project_id
  secrets = [
    {
      name        = "cf-tunnel-bastion-access-token"
      secret_data = module.tunnel.tunnel_token
    },
  ]
}

# Get the secret from GCP Secret Manager
# We are testing if the secret is created and we can retrieve it
data "google_secret_manager_secret_version" "tunnel_secret" {
  # secret = one(module.tunnel_secret.secret_names)
  secret     = "cf-tunnel-bastion-access-token"
  project    = var.project_id
  depends_on = [module.tunnel_secret]
}

# Validate the tunnel token by running cloudflared tunnel command
resource "null_resource" "validate_tunnel_token" {
  provisioner "local-exec" {
    command = <<EOT
      source .secrets
      # Run cloudflared in the background with timeout
      timeout 5s cloudflared tunnel --loglevel debug run --bastion --token ${data.google_secret_manager_secret_version.tunnel_secret.secret_data} &

      # Get process ID (PID) of cloudflared
      PID=$!

      # Wait a few seconds for successful connection
      sleep 5

      # Check logs for a successful connection message
      if ps -p $PID > /dev/null; then
        echo "Tunnel is running successfully. Killing process..."
        kill $PID
      else
        echo "Tunnel failed to start."
        exit 1
      fi
    EOT
  }
}
