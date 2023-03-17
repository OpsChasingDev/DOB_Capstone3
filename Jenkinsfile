#!/usr/bin/env groovy

// the below is the syntax to reference a shared library in Jenkins server scoped only to the project
library identifier: 'DOB_Jenkins-Shared-Library@main', retriever: modernSCM(
    [
        $class: 'GitSCMSource',
        remote: 'https://github.com/OpsChasingDev/DOB_Jenkins-Shared-Library.git',
        credentialsId: 'GitHub_PAT'
    ]
)

// the below would be used instead if the shared library is globally accessible in Jenkins server
// note the "_" at the end of the below line is necessary only if you do not have a "def gv" in between the library call and the rest of the pipeline syntax
// @Library('jenkins-shared-library')_

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
        stage('build and push image'){
            steps{
                script{
                    echo "building docker image..."
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }
        stage('provision server') {
            // this part before steps{} is what will give Terraform the necessary env vars to authenticate to AWS
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
                // this env var allows Jenkins to pass a value to Terraform for the var we defined in terraform script called "env_prefix"
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir ('terraform') {
                        echo 'provisioning ec2 instance...'
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                    }
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