pipeline {
  agent any

  environment {
    IMAGE = "rakeshramch/static_wab"
    TAG = "latest"
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
        powershell 'docker build -t $env:IMAGE:$env:TAG .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'dockerhub',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
          )
        ]) {
          powershell '$env:DOCKER_PASS | docker login -u $env:DOCKER_USER --password-stdin'
          powershell 'docker push $env:IMAGE:$env:TAG'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([
          file(credentialsId: 'kubeconfig_cred', variable: 'KCFG')
        ]) {
          powershell '''
            kubectl --kubeconfig=$env:KCFG set image deployment/static-site-deploy static-site=$env:IMAGE:$env:TAG
            kubectl --kubeconfig=$env:KCFG rollout status deployment/static-site-deploy
          '''
        }
      }
    }
  }

  post {
    always {
      powershell 'docker logout || echo "Logout failed but safe"'
    }
  }
}
