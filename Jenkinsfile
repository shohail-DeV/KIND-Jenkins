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
                  - name: kubectl
                    image: bitnami/kubectl:latest
                    command:
                    - sleep
                    args:
                    - infinity
            '''
        }
    }
    stages {
        stage('Build Docker Image') {
            steps {
                container('docker') {
                    sh 'docker build -t my-app:latest .'
                }
            }
        }
        stage('Load Image into kind') {
            steps {
                sh 'kind load docker-image my-app:latest --name jenkins-lab'
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