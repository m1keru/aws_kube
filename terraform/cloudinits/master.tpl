#cloud-config

write_files:
  - path: /etc/kubernetes/kubeadm.conf
    owner: root:root
    permissions: 0644
    content: |
      apiVersion: kubeadm.k8s.io/v1beta2
      kind: InitConfiguration
      nodeRegistration:
        name: CONTROL_PLANE_FQDN
        kubeletExtraArgs:
         cloud-provider: aws
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
      apiServer:
        extraArgs:
         cloud-provider: aws
      clusterName: kubernetes
      controllerManager:
        extraArgs:
         cloud-provider: aws
         configure-cloud-routes: "false"
      kubernetesVersion: ${kubernetes_version}
      controlPlaneEndpoint: CONTROL_PLANE_FQDN:6443
      networking:
        dnsDomain: eu-central-1.compute.internal
        podSubnet: 192.168.0.0/16
  - path: /etc/kubernetes/pvc_aws.yaml
    owner: root:root
    permissions: 0644
    content: |
      kind: StorageClass 
      apiVersion: storage.k8s.io/v1 
      metadata:
        name: standard 
      provisioner: kubernetes.io/aws-ebs 
      parameters:
        type: gp2
      reclaimPolicy: Retain 
      mountOptions: 
        - debug


runcmd:
  - sed -i "s/CONTROL_PLANE_IP/$(curl http://169.254.169.254/latest/meta-data/local-ipv4)/g" /etc/kubernetes/kubeadm.conf
  - sed -i "s/CONTROL_PLANE_FQDN/$(curl http://169.254.169.254/latest/meta-data/local-hostname)/g" /etc/kubernetes/kubeadm.conf
  - cat /etc/resolv.conf
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
  - kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f /etc/kubernetes/pvc_aws.yaml

final_message: "The system is finally up, after $UPTIME seconds"
