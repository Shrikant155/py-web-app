pipeline {
  agent any
  triggers {
  pollSCM('H/5 * * * *')
 } 
  stages {
     
     stage("code-fetch-git") {
       steps {
         git branch: 'main' ,
         credentialsId: 'github-cred-id' ,
         url: 'https://github.com/Shrikant155/py-web-app.git'
       }   
      }
     stage("build") {
       steps {
        sh 'docker build -t python-web-app .'   
     }
     }
     stage("push-img-to-hub") {
       steps {
         script {
           docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-cred-id') {
           def app = docker.build("shrikant155/python-web-app:${BUILD_NUMBER}")
           app.push()
           app.push('latest')
           }
         } 

        }

   }  


 }
post {
  always {
   sh 'docker system prune -f'
  }
}

}
