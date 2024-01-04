terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

resource "kubernetes_manifest" "prod_cert_manager" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt-prod"
      namespace = "vault"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  chart      = "vault"
  version    = "0.26.1"
  namespace  = "vault"
  repository = "https://helm.releases.hashicorp.com"

  values = [file("${path.module}/vault-values.yaml")]
}

resource "kubernetes_manifest" "vault_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"

    metadata = {
      name      = "ingress"
      namespace = "vault"

      annotations = {
        "kubernetes.io/ingress.class"  = "nginx"
        "cert-manager.io/issuer"       = "letsencrypt-prod"
        "cert-manager.io/duration"     = "2140h"
        "cert-manager.io/renew-before" = "1500h"
      }
    }

    spec = {
      tls = [
        {
          hosts      = [var.domain]
          secretName = "tls-certificate"
        }
      ]

      ingressClassName = "nginx"

      rules = [
        {
          host = var.domain

          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"

                backend = {
                  service = {
                    name = "vault-ui"
                    port = {
                      number = 8201
                    }
                  }
                }
              },
            ]
          }
        }
      ]
    }
  }
}
