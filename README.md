# tf-gitops-bridge

This repository demonstrates how to apply the Gitops Bridge pattern, as popularised by [Nicholas Morey](https://github.com/morey-tech).

This repository contains an app-of-apps directory (or in reality an app-of-appsets) which configures 
[kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), which
configures Prometheus and Grafana.

It also configures [external-dns](https://github.com/kubernetes-sigs/external-dns). This is more to showcase how values 
can be propagated into the chart from a cluster secret, since the external-dns configuration assumes that it is on AWS, 
which, if run in a local minikube/k3s/Docker Desktop it would not be.

This repository assumes that Argo CD has been installed somewhere (how that is done is an exercise for the reader), and
that Terraform has access to the cluster which it is installed on. The Kubeconfig can be set by setting the 
environment variable `KUBE_CONFIG_PATH`, or alternatively the Kubernetes provider can be set by using an 
[exec plugin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins). This has been 
tested using a local Argo CD 2.10 server.

The Terraform state management used in this repo is local, feel free to update the state to whichever state management 
required (TF Cloud, S3 + DynamoDB, GCS, etc. etc.)

external-dns is an `ApplicationSet` which currently only selects the local cluster. This is to showcase how an 
`ApplicationSet` can be used to deploy to a single (or multiple) cluster without the need to use labels.

kube-prometheus-stack is an appset which makes use of the [multiple sources](https://argo-cd.readthedocs.io/en/stable/user-guide/multiple_sources/)
feature. The reason for using this feature is for being able to make use of the upstream Helm chart, and for being able to
override some of the default values. This also makes use of label selectors, where it will match a label `environment`
with the values of `dev`, `staging` or `prod`.

There is only one environment with the single cluster, but the appset showcases how e.g. version promotion can work,
since we can select a distinct values repo ref and Helm chart version per environment (it's all currently the same version
for all envs though).

The values repo can be found [here](https://github.com/blakepettersson/argocd-kube-prometheus-stack), which contains
the overridden values. The values are more or less the defaults provided by the upstream Helm chart, except for it
not installing Alertmanager and any rules associated with it, and it also installs the standard Argo CD dashboard. It
also overrides the Grafana and Prometheus services to use `NodePort` instead of `ClusterIP`.

## TODOs
* Add a version using the [Argo CD Provider](https://github.com/oboukili/) instead of the native K8s provider  

## Usage

```shell
cd with-native-k8s-provider && terraform apply
```

