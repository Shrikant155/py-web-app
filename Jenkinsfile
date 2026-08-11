pipeline {
  agent any
  triggers {
  pollSCM('H/5 * * * *')
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
          timeout(time: 5, unit: 'MINUTES') {
             waitForQualityGate abortPipeline: true
          }

        }  
     

      }
     stage("build") {
       steps {
        sh '''
           docker rmi -f shrikant155/python-web-app || true 
           docker build -t shrikant155/python-web-app:${BUILD_NUMBER} -t shrikant155/python-web-app:latest .   
           '''   
             }
     }
     stage("trivy scan ") {
      steps {
        sh 'trivy image --severity HIGH, CRITICAL --exit-code 1 shrikant155/python-web-app:latest'

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
