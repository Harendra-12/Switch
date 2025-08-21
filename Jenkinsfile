pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "677276107791"            // Replace with your AWS Account ID
        AWS_REGION     = "us-east-2"               // Replace with your region
        REPO_NAME      = "freeswitch"              // Replace with your ECR repo name
        IMAGE_TAG      = "latest"                  // Could use BUILD_NUMBER or git commit SHA
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"
        SERVER_IP      = credentials('SERVER_IP')        // Jenkins credentials ID
        SERVER_USER    = credentials('SERVER_USER')      // Jenkins credentials ID
        SERVER_SSH_KEY = credentials('SERVER_SSH_KEY')   // Jenkins credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Harendra-12/YourRepo.git'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws --version
                aws ecr get-login-password --region ${AWS_REGION} \
                  | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${ECR_URL} ./docker/base_image
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                docker push ${ECR_URL}
                '''
            }
        }

        stage('Deploy to Webserver') {
            steps {
                sshagent (credentials: ['SERVER_SSH_KEY']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} << EOF
                        aws ecr get-login-password --region ${AWS_REGION} \
                          | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        docker pull ${ECR_URL}
                        docker stop freeswitch || true
                        docker rm freeswitch || true
                        docker run -d \
                          --name freeswitch \
                          -p 5060:5060/udp \
                          -p 5060:5060/tcp \
                          -p 5061:5061/tcp \
                          -p 8021:8021/tcp \
                          -p 7443:7443/tcp \
                          -p 16384-32768:16384-32768/udp \
                          -v /opt/freeswitch/conf:/etc/freeswitch \
                          -v /opt/freeswitch/log:/var/log/freeswitch \
                          -v /opt/freeswitch/db:/var/lib/freeswitch \
                          ${ECR_URL}
                    EOF
                    '''
                }
            }
        }
    }
}
