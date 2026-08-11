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


 }
}
