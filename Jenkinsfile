#!/usr/bin/env groovy

@Library('jenkins-shared-library')_

pipeline{
    agent any
    tools {
        maven 'Maven'
    }
    stages{
        stage("increment version") {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }
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
                    // add dockerLogin function to jenkins-shared-library
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
        stage("commit version update") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId:'GitHub_PAT', passwordVariable:'GITHUB_PAT_PASS', usernameVariable:'GITHUB_PAT_USER')]) {
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins-3.droplet"'
                        sh "git remote set-url origin https://${GITHUB_PAT_USER}:${GITHUB_PAT_PASS}@github.com/OpsChasingDev/DOB_Capstone3.git"
                        sh 'git add .'
                        sh 'git commit -m "incrementing app version"'
                        sh 'git push origin main'
                    }
                }
            }
        }
    }
}