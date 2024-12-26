#!/bin/bash

# Install MicroK8s
snap install microk8s --classic

# Add the ubuntu user to the MicroK8s group
usermod -aG microk8s ubuntu

# Enable essential MicroK8s add-ons
microk8s enable dns storage

# Allow some time for MicroK8s to start
sleep 30

# Configure the cluster
INSTANCE_INDEX=${instance_index}
CONTROL_PLANE_IP=${control_plane_ip}

if [ "$INSTANCE_INDEX" -eq 0 ]; then
  # This is the first node, set it up as the control plane
  microk8s enable ha-cluster
else
  # This is a secondary node, join it to the cluster
  JOIN_COMMAND=$(ssh -o StrictHostKeyChecking=no ubuntu@"$CONTROL_PLANE_IP" microk8s add-node | grep "microk8s join" | tail -n 1)
  eval $JOIN_COMMAND
fi
