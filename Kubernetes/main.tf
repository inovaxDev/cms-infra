terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace" "external_secrets_namespace" {
  metadata {
    name = "external-secrets"
  }
}

resource "helm_release" "external_secrets" {
  name      = "external-secrets"
  namespace = kubernetes_namespace.external_secrets_namespace.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart     = "external-secrets"
  version   = "0.9.8"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_namespace" "ingress_nginx_namespace" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx_controller" {
  name      = "ingress-nginx"
  namespace = kubernetes_namespace.ingress_nginx_namespace.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart     = "ingress-nginx"
  version   = "4.8.0"
}