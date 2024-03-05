locals {
  my-labels = {
    environment = "dev"
    aws-account-id = "09876543210"
  }
  my-annotations = {
    external-dns-iam-role-name = "my-external-dns-iam-role-name"
    cluster-dns-zone = "my-route53-zone.com"
  }
}

// With this approach we label each cluster with the metadata it requires for appsets to be properly installed. This can
// include things such as IAM roles etc.
resource "kubernetes_secret" "example" {
  metadata {
    name = "kubernetes.local.svc-cluster"
    # With labels, clusters can be filtered using a label selector in ApplicationSets.
    labels = merge({ "argocd.argoproj.io/secret-type" = "cluster" }, local.my-labels)
    # Annotations can also be used to insert data from a cluster into an ApplicationSet. If there is no need for an
    # attribute to be filtered in an ApplicationSet, the recommendation is to use annotations instead of labels.
    annotations = local.my-annotations
    namespace = "argocd"
  }

  data = {
    name = "kubernetes.default.svc"
    server = "https://kubernetes.default.svc"
  }

  type = "Opaque"
}

// The initial app-of-apps which initiates the whole enchilada.
resource "kubernetes_manifest" "app-of-apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
    }
    spec = {
      destination = {
        namespace = "argocd"
        server = "https://kubernetes.default.svc"
      }
      syncPolicy = {
        automated = {
          prune = true
          selfHeal = true
        }
      }
      source = {
        path = "appsets"
        # For simplicity this is all in the same repo.
        repoURL = "https://github.com/blakepettersson/tf-gitops-bridge.git"
        targetRevision = "HEAD"
      }
      project = "default"
    }
  }
}
