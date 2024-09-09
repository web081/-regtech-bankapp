```sh
pipeline {
    agent any
    tools{
    jdk 'jdk17'
    maven 'maven3'
    }
    environment {
        SCANNER_HOME= tool 'sonar-scanner'  
    }

    stages {

        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/web081/regtech-bankapp.git'
            }
          }

         
         stage('Compille') {
            steps {
                sh 'mvn compile'
            }
        } 
        stage('Test Java') {
            steps {
                sh 'mvn test'
            }
        } 
        stage('Trivy Fs Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        } 
        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Regtech-Bankapp -Dsonar.projectKey=Regtech-Bankapp \
                        -Dsonar.java.binaries=target'''
              }
            }
        } 
        stage('Build') {
            steps {
                sh 'mvn package'
            }
        } 
        stage('Publish To Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-setting', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                  sh 'mvn deploy'
                 }
             }
        } 
        stage('Docker Build Image') {
            steps {
                script{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh 'docker build -t bom234/bankapp:latest .'  
                 }
             }
            }
        } 
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html bom234/bankapp:latest"
            } 
        
        } 
        stage('Docker push Image') {
            steps {
                script{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh 'docker push bom234/bankapp:latest'  
                 }
             }
            }
        } 
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'regtech-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://1E780C46D7336BB46EFE950CF208FB4F.gr7.us-east-1.eks.amazonaws.com') {
                     sh 'kubectl apply -f regtec-ds.yml -n webapps'
                     sleep 30
               }
            }
        } 
        stage('verify deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'regtech-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://1E780C46D7336BB46EFE950CF208FB4F.gr7.us-east-1.eks.amazonaws.com') {
                     sh 'kubectl get pods -n webapps'
                     sh 'kubectl get svc -n webapps'
               }
            }
        } 
    }  
}
```
