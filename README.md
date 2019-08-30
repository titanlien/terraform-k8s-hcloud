# Terraform Kubernetes on Hetzner Cloud

This repository will help to setup an opionated Kubernetes Cluster with [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/) on [Hetzner Cloud](https://www.hetzner.com/cloud?country=us) and using AWS S3 as backend.

## Usage

```
$ git clone https://github.com/titanlien/terraform-k8s-hcloud.git
$ terraform init
$ terraform apply
```

## Provision with Ansible
```
cd ansible/
pipenv sync
ansible-playbook -e sshKey=/Users/titan/.ssh/id_rsa -i inventory site.yaml
```

## Variables

|  Name                    |  Default     |  Description                                                                      | Required |
|:-------------------------|:-------------|:----------------------------------------------------------------------------------|:--------:|
| `hcloud_token`              | ``           |API Token that will be generated through your hetzner cloud project https://console.hetzner.cloud/projects      | Yes      |
| `master_count`                  | `1`           | Amount of masters that will be created                                         | No      |
| `master_image`                 | `[SNAPSHOT_ID]`  | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-16.04, debian-9,centos-7,fedora-27)                                     | No      |
| `master_type`                   | `cx11`  | Machine type for more types have a look at https://www.hetzner.de/cloud                                   | No       |
| `node_count`             | `1`  | Amount of nodes that will be created                                 | No       |
| `node_image`                   | `[SNAPSHOT_ID]`         | Predefined Image that will be used to spin up the machines (Currently supported: ubuntu-16.04, debian-9,centos-7,fedora-27)       |
| `node_type`              | `cx11`          | Machine type for more types have a look at https://www.hetzner.de/cloud | No       |
| `ssh_private_key`                    | `~/.ssh/id_ras`    | Private Key to access the machines       |
| `ssh_public_key`          | `~/.ssh/id_rsa.pub`          | Public Key to authorized the access for the machines                                                     | No       |
| `docker_version`         | `19.03`          | Docker CE version that will be installed                                                     | No       |
| `kubernetes_version`         | `1.12.2`          | Kubernetes version that will be installed                                                     | No       |
| `core_dns`         | `false`          | Enables CoreDNS as Service Discovery                                                     | No       |
| `calico_enabled`         | `false`          | Installs Calico Network Provider after the master comes up                                                    | No       |
All variables cloud be passed through `environment variables` or a `tfvars` file.

An example for a `tfvars` file would be the following `terraform.tfvars`

```toml
# terraform.tfvars
hcloud_token = "<yourgeneratedtoken>"
master_type = "cx11"
master_count = 1
node_type = "cx11"
node_count = 1
```

Or passing directly via Arguments

```console
$ terraform apply \
  -var hcloud_token="<yourgeneratedtoken>"
  -var master_type=cx21
  -var master_count=1
  -var node_type=cx31
  -var node_count=2
```


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/titanlien/terraform-k8s-hcloud/issues) to report any bugs or file feature requests.


**Tested with**
- Terraform [v0.12.7](https://github.com/hashicorp/terraform/tree/v0.12.7)
- provider.hcloud [v1.12.0](https://github.com/hetznercloud/terraform-provider-hcloud/tree/v1.12.0)
- provider.null v2.1.2
- provider.template v2.1.2
