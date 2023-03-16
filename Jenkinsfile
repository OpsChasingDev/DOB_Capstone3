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
                    def dockerCmd = "docker run -p 8080:8080 -d ${IMAGE_NAME}"
                    sshagent(['EC2-Server-Key']) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@{{ ec2_ip }} ${dockerCmd}" // adjust {{ ec2_ip }}
                    }
                }
            }
        }
    }
}