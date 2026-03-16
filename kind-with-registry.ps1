# Create registry container
docker run -d --restart=always -p 5001:5000 --name kind-registry registry:2

# Create cluster config
$clusterConfig = @"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5001"]
        endpoint = ["http://kind-registry:5000"]
nodes:
  - role: control-plane
  - role: worker
  - role: worker
"@

$clusterConfig | Out-File -FilePath "kind-cluster.yaml" -Encoding utf8
kind create cluster --name jenkins-lab --config kind-cluster.yaml

# Connect registry to cluster network
docker network connect kind kind-registry