# DOB_Capstone3
Integrate the automated provisioning of an EC2 instance into the full app CI/CD pipeline.

In this project, we start with an existing Jenkins CI/CD pipeline which builds an app, creates a containerized image of the app, pushes the image to Docker repository, and then deploys the application onto a pre-provisioned EC2 instance.  Starting from this point, we will add a step into the full CI/CD pipeline that automatically provisions the EC2 instance on which the app will be deployed rather than needing to have it provisioned ahead of time manually.

## Jenkins Server Pre-requisites

1. Install SSH-Agent plugin
2. Add username-key credential type to allow Jenkins to authenticate against AWS with SSH
3. Create SSH key-pair which Jenkins will need for connecting against ec2 and add it to Jenkins credentials in UI
4. Install terraform on Jenkins container (steps for Debian distros below)
   1. Add hashicorp key
      ```Bash
      curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
      ```
   2. Update apt-get and install package that includes command apt-add-repository
      ```Bash
      apt-get update
      apt-get install software-properties-common
      ```
   3. Add hashicorp repository to apt
      ```Bash
      apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      ```
   4. Install terraform
      ```Bash
      apt-get update && apt-get install terraform
      ```