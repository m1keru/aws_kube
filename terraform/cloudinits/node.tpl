#cloud-config

write_files:
  - path: /etc/kubernetes/node.conf
    owner: root:root
    permissions: 0644
    content: |
        apiVersion: kubeadm.k8s.io/v1beta1
        kind: JoinConfiguration
        discovery:
            bootstrapToken:
                apiServerEndpoint: "${control_plane_ip}:6443"
                token: "${bootstrap_token}"
                unsafeSkipCAVerification: true
        nodeRegistration:
            name: NODE_FQDN
            kubeletExtraArgs:
                cloud-provider: aws


runcmd:
  - sed -i "s/NODE_FQDN/$(curl http://169.254.169.254/latest/meta-data/local-hostname)/g" /etc/kubernetes/node.conf
#  - echo kubeadm join --token=${bootstrap_token} --discovery-token-unsafe-skip-ca-verification ${control_plane_ip}:6443
  - echo kubeadm join --config /etc/kubernetes/node.conf 
  - for i in $(seq 10); do echo "kubeadm join $i" && kubeadm join --config /etc/kubernetes/node.conf && break || sleep 15; done

final_message: "The system is finally up, after $UPTIME seconds"
