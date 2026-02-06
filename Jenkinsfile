pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rakeshramch/static-web"
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBE_NAMESPACE = "default"
        DEPLOYMENT_NAME = "static-web-deployment"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/rakeshramch85-eng/static-wabsite.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat "echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin"
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                    kubectl version --client
                    kubectl set image deployment/%DEPLOYMENT_NAME% static-web=%DOCKER_IMAGE%:%DOCKER_TAG% -n %KUBE_NAMESPACE%
                    kubectl rollout status deployment/%DEPLOYMENT_NAME% -n %KUBE_NAMESPACE%
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Windows Jenkins: Docker image pushed & K8s deployment updated"
        }
        failure {
            echo "❌ Pipeline Failed on Windows"
        }
    }
}
