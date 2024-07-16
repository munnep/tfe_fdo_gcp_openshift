data "aws_route53_zone" "base_domain" {
  name = var.dns_zonename
}


resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = "${var.dns_hostname}.${var.dns_zonename}"

  recursive_nameservers        = ["1.1.1.1:53"]
  disable_complete_propagation = true

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = data.aws_route53_zone.base_domain.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}


resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.certificate_email
}


# resource "acme_certificate" "certificate" {
#   account_key_pem = acme_registration.registration.account_key_pem
#   common_name     = "${var.dns_hostname}.${var.dns_zonename}"

#   dns_challenge {
#     provider = "gcloud"

#     config = {
#       GCE_PROJECT = data.terraform_remote_state.infra.outputs.gcp_project
#     }
#   }
# }

# data "google_dns_managed_zone" "base_domain" {
#   # name   = var.dns_zonename
#   name = "doormat-accountid"
#   project = var.gcp_project
# }


# data "kubernetes_service" "example" {
#   metadata {
#     name      = local.namespace
#     namespace = local.namespace
#   }
#   depends_on = [helm_release.tfe]
# }

# resource "google_dns_record_set" "tfe" {
#   name         = "${var.dns_hostname}.${data.google_dns_managed_zone.selected.dns_name}"
#   type         = "A"
#   ttl          = 300
#   managed_zone = data.google_dns_managed_zone.selected.name

#   rrdatas = [data.kubernetes_service.example.status.load_balancer_ingress[0].ip]

#   depends_on = [helm_release.tfe]
# }


data "aws_route53_zone" "selected" {
  name         = var.dns_zonename
  private_zone = false
}


data "kubernetes_service" "example" {
  metadata {
    name      = local.namespace
    namespace = local.namespace
  }
  depends_on = [helm_release.tfe]
}



resource "aws_route53_record" "tfe" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_hostname
  type    = "A"
  ttl     = "300"
  records = [data.kubernetes_service.example.status.0.load_balancer.0.ingress.0.ip]

  depends_on = [helm_release.tfe]
}


