# microk8s on AWS Lightsail

## Goals
Quickly deploy a somewhat resilient k8s cluster on AWS without a bunch of extra garbage. Assumes you will use Cloudflare or NGrok to do tunnels and ingress via tunnel.

### How It Works
1. The **first instance (index 0)** initializes the HA cluster using `microk8s enable ha-cluster`.
2. Subsequent instances (indices 1, 2, ...) join the cluster using the `microk8s join` command, dynamically obtained from the first node.
3. **Dynamic Configuration**: The `setup_microk8s.sh` script uses Terraform's templating to inject the index and control plane IP into the setup script.

### Usage
1. **Run Terraform Commands**:
```bash
terraform init
terraform apply
```

2. **Access the Cluster**:
- Connect to the first node (control plane) to manage the cluster:
  ```bash
  ssh -i <path-to-private-key> ubuntu@<control-plane-ip>
  microk8s status
  ```
   
 3. **Verify HA Setup**:
 - Ensure all nodes are part of the HA cluster:
  ```bash
  microk8s status
  ```

### Notes
- **Instance Networking**: Lightsail instances must have networking rules allowing communication on required ports (2379, 25000, etc) on private network (this is the default)
- **External Networking**: Lightsail Firewall allows SSH and k8s API to the outside world. Lock these down further (via bastion or IP restriction) for better security.

