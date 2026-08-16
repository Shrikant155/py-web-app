pipeline {
  agent any
  environment {
   AWS_ACCESS_KEY_ID=credentials('aws-cred-id')
  AWS_SECRET_ACCESS_KEY=credentials('aws-secret-cred-id')
   AWS_REGION =  'eu-north-1'  
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
            
             echo "yes" |  terraform init -migrate-state
               
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
               script {
                 env.ECR_REPO = sh(script: "terraform output -raw ecr_url",returnStdout: true).trim()

               }
            }

       }
     }
     stage("scan-and-build") {
       steps {
        sh '''
         
           /home/shrikant-devops/.local/bin/checkov -f Dockerfile --quiet
           
           docker rmi -f shrikant155/python-web-app:${BUILD_NUMBER} || true 
           docker build --no-cache -t shrikant155/python-web-app:${BUILD_NUMBER}  .   
         

             '''   
             }
     }
     stage("trivy scan ") {
      steps {
        sh 'trivy image  shrikant155/python-web-app:${BUILD_NUMBER}'

      }

     } 

/*     stage("login & push to hub") {
        steps {
         script {
          docker.withRegistry("https://index.docker.io/v1/","dockerhub-cred-id") { 
             
           def image = docker.image("shrikant155/python-web-app:${BUILD_NUMBER}")
           image.push()
           
           }         
         }
        }
     }*/
      stage("push-to-ecr") {
        steps {
         sh '''
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO} 
            docker tag  shrikant155/python-web-app:${BUILD_NUMBER} ${ECR_REPO}:${BUILD_NUMBER}
            docker push ${ECR_REPO}:${BUILD_NUMBER}
            '''
        }
      }
/*     stage('deploy-on-host') {
       steps {
         sh '''
             docker run -d -p 5000:5000 shrikant155/python-web-app:latest
           '''
       }
     } */

      stage("deploy-from-ecr") {
         steps {
          sh '''
             aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
             #docker stop python-web-app || true
             #docker rm python-web-app || true
             docker pull ${ECR_REPO}:${BUILD_NUMBER}
             
             #docker run -d --name python-web-app -p 5000:5000 ${ECR_REPO}:${BUILD_NUMBER}
             minikube status >/dev/null 2>&1 || minikube start --driver=docker
             minikube image load ${ECR_REPO}:${BUILD_NUMBER}
             sed -i "s|__IMAGE_NAME__|${ECR_REPO}:${BUILD_NUMBER}|g" deployment.yml
             kubectl apply -f deployment.yml
             kubectl apply -f service.yml
             minikube service  py-k8s-app-service
             '''
         }  
      }
   }
              
post {
  success {
     mail to: "shrikantdevops999@gmail.com",
          subject: "job done successful:${JOB_NAME}" ,
          body: """
                 job successful.
                 job-name: ${JOB_NAME}
                 build-number: ${BUILD_NUMBER}
                  url:${BUILD_URL}
                  """
  }
  failure {
   echo 'somthing is failed'
  }
  always {
   sh 'docker system prune -f '
  sh 'docker logout || true'
  }
}

}
