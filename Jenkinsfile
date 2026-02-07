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
            steps {
                git branch: 'main',
                    url: 'https://github.com/rakeshramch85-eng/static-wabsite.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat """
                docker version || exit 1
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
                    docker logout
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    """
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                bat """
                docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                """
            }
        }

        stage('Docker Pull Verification') {
            steps {
                bat """
                docker pull %DOCKER_IMAGE%:%DOCKER_TAG%
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                    kubectl get nodes

                    kubectl apply -f deployment.yaml -n %KUBE_NAMESPACE%
                    kubectl apply -f service.yaml -n %KUBE_NAMESPACE%

                    kubectl set image deployment/%DEPLOYMENT_NAME% %CONTAINER_NAME%=%DOCKER_IMAGE%:%DOCKER_TAG% -n %KUBE_NAMESPACE%

                    kubectl rollout status deployment/%DEPLOYMENT_NAME% -n %KUBE_NAMESPACE%
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Jenkins CI/CD SUCCESS – Docker & Kubernetes deployed 🚀"
        }
        failure {
            echo "❌ Jenkins CI/CD FAILED – Check Docker or Kubernetes logs"
        }
    }
}
