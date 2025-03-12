def remote = [:]
pipeline {
    agent any
    parameters {
        choice(name: 'DOCKERFILE', choices: ['Dockerfile-nginx', 'Dockerfile-php', 'Dockerfile-ruby'], description: 'Выберите Dockerfile для сборки')
        booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Выполнять ли деплой?')
    }
    environment {
        REPO = "zabella/jenkins_params_ex"
        IMAGE_TAG = "${env.REPO}:${env.BUILD_ID}"
        HOST = "3.16.38.170"
        SVC = "action"
    }
    
    
        stage('Configure credentials') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins_key', keyFileVariable: 'private_key', usernameVariable: 'username')]) {
                    script {
                        remote.name = "${env.HOST}"
                        remote.host = "${env.HOST}"
                        remote.user = "$username"
                        remote.identity = readFile("$private_key")
                        remote.allowAnyHosts = true
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Сборка с использованием файла ${params.DOCKERFILE}"
                    sh "docker build -f ${params.DOCKERFILE} -t ${IMAGE_TAG} ."
                }
            }
        }
        stage('Push to Docker Hub') {
            environment {
                registry_token = credentials('docker_hub1')
            }
            steps {
                script {
                    echo "Публикация Docker образа в Docker Hub..."
                    sh "docker login -u zabella -p ${registry_token}"
                    sh "docker push ${IMAGE_TAG}"
                }
            }
        }
        stage('Deploy application') {
            when {
                expression { return params.RUN_DEPLOY }
            }
            environment {
                registry_token = credentials('docker_hub1')
            }
            steps {
                script {
                    sshCommand remote: remote, command: """
                        set -ex ; set -o pipefail
                        docker login -u zabella -p ${registry_token}
                        docker pull ${IMAGE_TAG}
                        docker rm ${env.SVC} --force 2> /dev/null || true
                        docker run -d -it --name ${env.SVC} "${IMAGE_TAG}"
                    """
                }
            }
        }
    }
}

