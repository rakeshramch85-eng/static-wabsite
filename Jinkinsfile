pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "amarjeet001/static-web"
        DOCKER_TAG = "19"
        CONTAINER_NAME = "static-website"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/amarjeetchaurasiya27-cyber/static-website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    """
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
            }
        }

        stage('Deploy Container') {
            steps {
                bat """
                docker stop %CONTAINER_NAME% 2>nul || echo No running container
                docker rm %CONTAINER_NAME% 2>nul || echo No container to remove
                docker run -d -p 7765:80 --name %CONTAINER_NAME% %DOCKER_IMAGE%:%DOCKER_TAG%
                """
            }
        }
    }

    post {
        success {
            echo "✅ Image pushed successfully & App deployed at http://<JENKINS-IP>:7765"
        }
        failure {
            echo "❌ Pipeline Failed"
        }
    }
}
