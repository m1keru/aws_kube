#cloud-config

write_files:
  - path: /etc/kubernetes/kubeadm.conf
    owner: root:root
    permissions: 0644
    content: |
      apiVersion: kubeadm.k8s.io/v1beta2
      kind: InitConfiguration
      bootstrapTokens:
      - groups:
        - system:bootstrappers:kubeadm:default-node-token
        token: ${bootstrap_token}
        ttl: 0s
        usages:
        - signing
        - authentication
      ---
      apiVersion: kubeadm.k8s.io/v1beta2
      kind: ClusterConfiguration
      kubernetesVersion: ${kubernetes_version}
      controlPlaneEndpoint: CONTROL_PLANE_IP:6443
      networking:
        podSubnet: 192.168.0.0/16

runcmd:
  - sed -i "s/CONTROL_PLANE_IP/$(curl http://169.254.169.254/latest/meta-data/local-ipv4)/g" /etc/kubernetes/kubeadm.conf
  - kubeadm init --config /etc/kubernetes/kubeadm.conf
  - mkdir -p /home/admin/.kube
  - cp -f /etc/kubernetes/admin.conf /home/admin/.kube/config
  - chown admin:admin /home/admin/.kube/config
  - mkdir -p /root/.kube
  - cp  /etc/kubernetes/admin.conf /root/.kube/config
  - echo 'source <(kubectl completion bash)' >> /root/.bashrc
  - echo 'source <(kubectl completion bash)' >> /home/admin/.bashrc
  - echo "DEBUG_LINE"
  - wget  https://docs.projectcalico.org/v3.8/manifests/calico.yaml
  - kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f calico.yaml

final_message: "The system is finally up, after $UPTIME seconds"
