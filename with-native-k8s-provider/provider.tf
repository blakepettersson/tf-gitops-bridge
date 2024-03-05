# For this example we get the kubeconfig path from the environment variable KUBE_CONFIG_PATH. This could also be a token
# fetched with aws eks get-token, or whatever equivalents there are for Azure or GKE.
provider "kubernetes" {
  #config_path    = "~/.kube/config"
}

