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
  name       = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets_namespace.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.8"

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
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx_namespace.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.0"
}

resource "kubernetes_namespace" "vault_namespace" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "consul" {
  name       = "consul"
  chart      = "consul"
  version    = "1.1.2"
  namespace  = kubernetes_namespace.vault_namespace.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"

  depends_on = [kubernetes_namespace.vault_namespace]

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [file("${path.module}/consul-values.yaml")]
}

resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager_namespace.metadata[0].name
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.13.3"

  depends_on = [kubernetes_namespace.cert_manager_namespace]

  set {
    name  = "installCRDs"
    value = "true"
  }
}
