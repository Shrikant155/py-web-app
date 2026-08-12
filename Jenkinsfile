pipeline {
  agent any
  environment {
   AWS_ACCESS_KEY_ID=credentials('aws-cred-id')
  AWS_SECRET_ACCESS_KEY=credentials('aws-secret-cred-id')
 } 
  stages {
     
     stage("code-fetch-git") {
       steps {
         git branch: 'main',
         credentialsId: 'github-cred-id' ,
         url: 'https://github.com/Shrikant155/py-web-app.git'
       }   
      }
     
     stage("sast-scan"){
       steps {
        script {
         withSonarQubeEnv("shrikant-sonar-scanner") {
           sh '/opt/sonar-scanner/bin/sonar-scanner'
         }
        }

       }

     }
      stage("quality-gate") {
        steps {
         catchError(buildResult: 'SUCCESS',stageResult: 'UNSTABLE' ) {
            timeout(time: 1, unit: 'MINUTES') {
             waitForQualityGate abortPipeline: false
             }
       }   }
      }
      stage("iac-init-scan") {
       steps {
         dir("terraform") {
          sh '''
             terraform init 
              /home/shrikant-devops/.local/bin/checkov -d .
            
             '''
           }
        }
       }

     
     stage("iac-plan-apply") {
       steps {
         dir("terraform") {
           sh '''
              terraform plan -out=tfplan 
              terraform apply --auto-approve  tfplan
              '''
         }

       }
     }
     stage("build") {
       steps {
        sh '''
           docker rmi -f shrikant155/python-web-app || true 
           docker build --no-cache -t shrikant155/python-web-app:${BUILD_NUMBER} -t shrikant155/python-web-app:latest .   
           '''   
             }
     }
     stage("trivy scan ") {
      steps {
        sh 'trivy image  shrikant155/python-web-app:latest'

      }

     } 

     stage("login & push to hub") {
        steps {
         script {
          docker.withRegistry("https://index.docker.io/v1/","dockerhub-cred-id") { 
             
           def image = docker.image("shrikant155/python-web-app:${BUILD_NUMBER}")
           image.push()
           image.push('latest')
           }         
         }
        }
     }
     stage('deploy-on-host') {
       steps {
         sh '''
             docker run -d -p 5000:5000 shrikant155/python-web-app:latest
           '''
       }
     }
}          
post {
  success {
   echo ' buildand fetch success'
  }
  failure {
   echo 'somthing is failed'
  }
  always {
   sh 'docker system prune -f'
  sh 'docker logout || true'
  }
}

}
