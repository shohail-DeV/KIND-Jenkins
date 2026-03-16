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
                    image: bitnami/kubectl:latest
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
                        # Configure Docker to allow insecure registry
                        mkdir -p /etc/docker
                        echo '{"insecure-registries":["kind-registry:5000"]}' > /etc/docker/daemon.json
                        
                        # Restart docker daemon to apply config
                        kill -SIGHUP $(cat /var/run/docker.pid) || true
                        sleep 3
                        
                        # Build and push
                        docker build -t $IMAGE .
                        docker push $IMAGE
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh 'kubectl apply -f k8s/'
                }
            }
        }
    }
}