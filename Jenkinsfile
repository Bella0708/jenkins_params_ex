pipeline {
    agent any
    parameters {
        choice(name: 'DOCKERFILE', choices: ['Dockerfile-nginx', 'Dockerfile-php', 'Dockerfile-ruby'], description: 'Выберите Dockerfile для сборки')
        booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Выполнять ли деплой?')
    }
    environment {
        REPO = "zabella/jenkins_params_ex"
        IMAGE_TAG = "${env.REPO}:${env.BUILD_ID}"
    }
     stage('Clone Repository') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: "${branch}"]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins_key', url: git_url]]])
            }
        } 
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Сборка с использованием файла ${params.DOCKERFILE}"
                    sh "docker build -f ${params.DOCKERFILE} -t ${IMAGE_TAG} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Публикация Docker образа в Docker Hub..."
                    docker.withRegistry('https://registry-1.docker.io', 'hub_token') {
                        image.push()
                    }
                }
            }
        }
        stage('Deploy to Remote Host') {
            when {
                expression { return params.RUN_DEPLOY }
            }
            steps {
                script {
                    echo "Выполняется деплой на удалённый хост..."
                    sshagent(['remote-host-credentials']) {
                        sh """
                        ssh user@remote-host "docker pull ${IMAGE_TAG} && docker run -d --name app-container ${IMAGE_TAG}"
                        """
                    }
                }
            }
        }
    }
}
