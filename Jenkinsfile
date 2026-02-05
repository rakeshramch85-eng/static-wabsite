pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "rakeshramch/static-web"
        DOCKER_TAG = "${BUILD_NUMBER}"
        CONTAINER_NAME = "static-website"
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
                bat 'docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .'
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat 'echo %DOCKER_PASS% | docker login -u %rakeshramch% --Ramch@123-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                bat 'docker push %rakeshramch/static-web%:%/static-web1%'
            }
        }

        stage('Deploy Container') {
            steps {
                bat '''
                docker stop %CONTAINER_NAME% 2>nul || echo No running container
                docker rm %CONTAINER_NAME% 2>nul || echo No container to remove
                docker run -d -p 7765:80 --name %CONTAINER_NAME% %DOCKER_IMAGE%:%DOCKER_TAG%
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Website live at: http://<SERVER-IP>:7765"
        }
        failure {
            echo "❌ Pipeline Failed – check logs"
        }
    }
}
