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

resource "kubernetes_manifest" "homolog_cert_manager" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-homolog"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-homolog"
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


resource "kubernetes_manifest" "prod_cert_manager" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
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

  # depends_on = [ kubernetes_manifest.tls_server_certificate ]

  values = [file("${path.module}/vault-values.yaml")]
}

resource "kubernetes_manifest" "vault_ingress" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"

    metadata = {
      name      = "vault-ingress"
      namespace = "vault"

      annotations = {
        "kubernetes.io/ingress.class"    = "nginx"
        "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      }
    }

    spec = {
      tls = [
        {
          hosts      = [var.domain]
          secretName = "vault-tls-certificate"
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
