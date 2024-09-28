---
title: 添加 Linux 工作节点
content_type: task
weight: 10
---
<!--
title: Adding Linux worker nodes
content_type: task
weight: 10
-->

<!-- overview -->

<!--
This page explains how to add Linux worker nodes to a kubeadm cluster.
-->
本页介绍如何将 Linux 工作节点添加到 kubeadm 集群。

## {{% heading "prerequisites" %}}

<!--
* Each joining worker node has installed the required components from
[Installing kubeadm](/docs/setup/production-environment/tools/kubeadm/install-kubeadm/), such as,
kubeadm, the kubelet and a {{< glossary_tooltip term_id="container-runtime" text="container runtime" >}}.
* A running kubeadm cluster created by `kubeadm init` and following the steps
in the document [Creating a cluster with kubeadm](/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
* You need superuser access to the node.
-->
* 每个要加入的工作节点都已安装
  [安装 kubeadm](/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
  中所需的组件，例如 kubeadm、kubelet 和
  {{< glossary_tooltip term_id="container-runtime" text="容器运行时" >}}。
* 一个正在运行的、由 `kubeadm init` 命令所创建的 kubeadm 集群，且该集群的创建遵循
  [使用 kubeadm 创建集群](/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
  文档中所给的步骤。
* 你需要对节点拥有超级用户权限。

<!-- steps -->

<!--
## Adding Linux worker nodes

To add new Linux worker nodes to your cluster do the following for each machine:

1. Connect to the machine by using SSH or another method.
1. Run the command that was output by `kubeadm init`. For example:

### Additional information for kubeadm join
-->
## 添加 Linux 工作节点   {#additional-information-for-kubeadm-join}

要将新的 Linux 工作节点添加到集群中，请对每台机器执行以下步骤：

1. 通过 SSH 或其他方式连接到该机器。
1. 运行 `kubeadm init` 所输出的命令。例如：

  ```bash
  sudo kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
  ```

### kubeadm join 的额外信息   {#additional-information-for-kubeadm-join}

{{< note >}}
<!--
To specify an IPv6 tuple for `<control-plane-host>:<control-plane-port>`, IPv6 address must be enclosed in square brackets, for example: `[2001:db8::101]:2073`.
-->
要为 `<control-plane-host>:<control-plane-port>` 指定一个 IPv6 元组，
IPv6 地址必须用方括号括起来，例如：`[2001:db8::101]:2073`。
{{< /note >}}

<!--
If you do not have the token, you can get it by running the following command on the control plane node:
-->
如果你没有令牌，可以在控制平面节点上运行以下命令来获取：

<!--
# Run this on a control plane node
-->
```bash
# 在控制平面节点上运行此命令
sudo kubeadm token list
```

<!--
The output is similar to this:
-->
命令输出同以下内容类似：

```console
TOKEN                    TTL  EXPIRES              USAGES           DESCRIPTION            EXTRA GROUPS
8ewj1p.9r9hcjoqgajrj4gi  23h  2018-06-12T02:51:28Z authentication,  The default bootstrap  system:
                                                   signing          token generated by     bootstrappers:
                                                                    'kubeadm init'.        kubeadm:
                                                                                           default-node-token
```

<!--
By default, node join tokens expire after 24 hours. If you are joining a node to the cluster after the
current token has expired, you can create a new token by running the following command on the
control plane node:
-->
默认情况下，节点加入令牌会在 24 小时后过期。当前令牌过期后，如果想把节点加入集群，
可以在控制平面节点上运行以下命令来创建新令牌：

<!--
# Run this on a control plane node
-->
```bash
# 在控制平面节点上运行此命令
sudo kubeadm token create
```

<!--
The output is similar to this:
-->
命令输出同以下内容类似：

```console
5didvk.d09sbcov8ph2amjw
```

<!--
If you don't have the value of `--discovery-token-ca-cert-hash`, you can get it by running the
following commands on the control plane node:
-->
如果你没有 `--discovery-token-ca-cert-hash` 的具体值，可以在控制平面节点上运行以下命令来获取：

<!--
# Run this on a control plane node
-->
```bash
# 在控制平面节点上运行此命令
sudo cat /etc/kubernetes/pki/ca.crt | openssl x509 -pubkey  | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

<!--
The output is similar to:
-->
命令输出同以下内容类似：

```console
8cb2de97839780a412b93877f8507ad6c94f73add17d5d7058e91741c9d5ec78
```

<!--
The output of the `kubeadm join` command should look something like:
-->
`kubeadm join` 命令的输出应该同下面内容类似：

```
[preflight] Running pre-flight checks

... (log output of join workflow) ...

Node join complete:
* Certificate signing request sent to control-plane and response
  received.
* Kubelet informed of new secure connection details.

Run 'kubectl get nodes' on control-plane to see this machine join.
```

<!--
A few seconds later, you should notice this node in the output from `kubectl get nodes`.
(for example, run `kubectl` on a  control plane node).
-->
几秒钟后，你应该在 `kubectl get nodes` 的输出中看到该节点。
（例如，可以在控制平面节点上运行 `kubectl`）。

{{< note >}}
<!--
As the cluster nodes are usually initialized sequentially, the CoreDNS Pods are likely to all run
on the first control plane node. To provide higher availability, please rebalance the CoreDNS Pods
with `kubectl -n kube-system rollout restart deployment coredns` after at least one new node is joined.
-->
集群节点通常是按顺序初始化的，因此 CoreDNS Pods 可能会全部运行在第一个控制平面节点上。
为了保证高可用，请在至少一个新节点加入后，使用
`kubectl -n kube-system rollout restart deployment coredns` 命令重新平衡 CoreDNS Pods。
{{< /note >}}

## {{% heading "whatsnext" %}}

<!--
* See how to [add Windows worker nodes](/docs/tasks/administer-cluster/kubeadm/adding-windows-nodes/).
-->
* 参见如何[添加 Windows 工作节点](/zh-cn/docs/tasks/administer-cluster/kubeadm/adding-windows-nodes/)。