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

        stage('Create / Update Kubernetes (Windows)') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    bat """
                    echo apiVersion: apps/v1> deployment.yaml
                    echo kind: Deployment>> deployment.yaml
                    echo metadata:>> deployment.yaml
                    echo   name: %DEPLOYMENT_NAME%>> deployment.yaml
                    echo spec:>> deployment.yaml
                    echo   replicas: 2>> deployment.yaml
                    echo   selector:>> deployment.yaml
                    echo     matchLabels:>> deployment.yaml
                    echo       app: static-web>> deployment.yaml
                    echo   template:>> deployment.yaml
                    echo     metadata:>> deployment.yaml
                    echo       labels:>> deployment.yaml
                    echo         app: static-web>> deployment.yaml
                    echo     spec:>> deployment.yaml
                    echo       containers:>> deployment.yaml
                    echo       - name: static-web>> deployment.yaml
                    echo         image: %DOCKER_IMAGE%:%DOCKER_TAG%>> deployment.yaml
                    echo         ports:>> deployment.yaml
                    echo         - containerPort: 80>> deployment.yaml

                    echo apiVersion: v1> service.yaml
                    echo kind: Service>> service.yaml
                    echo metadata:>> service.yaml
                    echo   name: static-web-service>> service.yaml
                    echo spec:>> service.yaml
                    echo   type: NodePort>> service.yaml
                    echo   selector:>> service.yaml
                    echo     app: static-web>> service.yaml
                    echo   ports:>> service.yaml
                    echo   - port: 80>> service.yaml
                    echo     targetPort: 80>> service.yaml
                    echo     nodePort: 30007>> service.yaml

                    kubectl apply -f deployment.yaml -n %KUBE_NAMESPACE%
                    kubectl apply -f service.yaml -n %KUBE_NAMESPACE%
                    kubectl rollout status deployment/%DEPLOYMENT_NAME% -n %KUBE_NAMESPACE%
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ WINDOWS Jenkins: Docker build → Push → Kubernetes Deploy SUCCESS"
            echo "🌐 App: http://<NODE-IP>:30007"
        }
        failure {
            echo "❌ Pipeline Failed on Windows"
        }
    }
}
