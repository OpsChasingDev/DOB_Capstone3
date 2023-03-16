#!/usr/bin/env groovy

library identifiers: 'jenkins-pipeline-shared-libraries@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'shared-libraries-repo.git', //adjust 'shared-libraries-repo.git'
    credentialsId: 'GitHub'
    ]
)

pipeline{
    agent any
    tools {
        maven 'Maven'
    }
    environment {
        IMAGE_NAME = {{ image_name }} // adjust {{ image_name }}
    }
    stages{
        stage('build app'){
            steps{
                script{
                    echo "building application jar..."
                    buildJar()
                }
            }
        }
        stage('build image'){
            steps{
                script{
                    echo "building docker image..."
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }
        stage('deploy'){
            steps{
                script{
                    echo "deploying docker image to ec2..."

                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@{{ ec2_ip }}" // adjust {{ ec2_ip }}

                    sshagent(['EC2-Server-Key']) {
                        sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }
        }
    }
}