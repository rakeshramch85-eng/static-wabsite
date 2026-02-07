pipeline {
    agent any

    environment {
        DOCKER_IMAGE    = "rakeshramch/static-web"
        DOCKER_TAG      = "${BUILD_NUMBER}"
        KUBE_NAMESPACE  = "default"
        DEPLOYMENT_NAME = "static-web-deployment"
        CONTAINER_NAME  = "static-web"
    }

    stages {

        stage('Checkout Code') {
            seen {
                git branch: 'main',
                    url: 'https://github.com/rakeshramch85-eng/static-wabsite.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                echo ===== Docker Version =====
                docker version || exit 1

                echo ===== Building Image =====
                docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                """
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                    echo ===== Docker Login =====
                    docker logout
                    docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                    """
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                bat """
                echo ===== Docker Images =====
                docker images

                echo ===== Pushing Image =====
                docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                    echo ===== Kubectl Client =====
                    kubectl version --client

                    echo ===== Cluster Nodes =====
                    kubectl get nodes

                    echo ===== Apply YAML Files =====
                    kubectl apply -f deployment.yaml -n %KUBE_NAMESPACE%
                    kubectl apply -f service.yaml -n %KUBE_NAMESPACE%

                    echo ===== Update Image =====
                    kubectl set image deployment/%DEPLOYMENT_NAME% %CONTAINER_NAME%=%DOCKER_IMAGE%:%DOCKER_TAG% -n %KUBE_NAMESPACE%

                    echo ===== Rollout Status =====
                    kubectl rollout status deployment/%DEPLOYMENT_NAME% -n %KUBE_NAMESPACE%
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD Success: Docker image pushed & Kubernetes deployed 🚀"
        }
        failure {
            echo "❌ Pipeline Failed – Check Docker Push or Kubernetes logs"
        }
    }
}
