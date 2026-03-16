pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: docker
                    image: docker:24-dind
                    securityContext:
                      privileged: true
                    env:
                    - name: DOCKER_TLS_CERTDIR
                      value: ""
                  - name: kubectl
                    image: alpine/k8s:1.28.3
                    command:
                    - sleep
                    args:
                    - infinity
            '''
        }
    }
    environment {
        IMAGE = "kind-registry:5000/my-app:latest"
    }
    stages {
        stage('Build & Push Image') {
            steps {
                container('docker') {
                    sh '''
                        mkdir -p /etc/docker
                        echo '{"insecure-registries":["kind-registry:5000"]}' > /etc/docker/daemon.json
                        kill -SIGHUP $(cat /var/run/docker.pid) || true
                        sleep 3
                        docker build -t $IMAGE .
                        docker push $IMAGE
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl apply -f k8s/
                        kubectl rollout status deployment/my-app -n default --timeout=60s
                    '''
                }
            }
        }
    }
}