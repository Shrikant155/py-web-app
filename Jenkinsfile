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
        sh '''
           docker rmi -f shrikant155/python-web-app || true 
           docker build -t shrikant155/python-web-app:${BUILD_NUMBER} -t shrikant155/python-web-app:latest .   
           '''   
             }
     }
          
post {
  success {
   echo ' buildand fetch success'
  }
  failure {
   echo "somthing is failed'
  }
  always {
   sh 'docker system prune -f'
  }
}

}
