pipeline {
    agent any
    
    tools{
        jdk 'jdk'
        maven 'maven3'
    }
environment {
    SCANNER_HOME= tool 'SonarScanner'
}
    stages {
        stage('Git Checkout') {
            steps {
                git 'https://github.com/ashenjay/Java-App.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html . "
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('Sonar-Scanner') {
             sh'''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=SMS-app -Dsonar.projectKey=SMS-app \
                    -Dsonar.java.binaries=target'''
            }
            }
        }
        
        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        
        stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
             }
            }
        }
        
        stage('Docker Build') {
            steps {
                script{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                 sh "docker build -t ashenjay/sms-app:latest ."
              }
             }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html ashenjay/sms-app:latest "
            }
        }
        
        stage('Docker Push Image') {
            steps {
                script{
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                 sh "docker push ashenjay/sms-app:latest"
              }
             }
            }
        }
        
        stage('K8-Deploy') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'terraform-cluster', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://A0262F4B6742037BA3499192324E1FEA.gr7.us-east-1.eks.amazonaws.com') {
                sh "kubectl apply -f deployment-service.yml"
                sleep 20
             }
            }
        }
        
        stage('K8-Verify the Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'terraform-cluster', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://A0262F4B6742037BA3499192324E1FEA.gr7.us-east-1.eks.amazonaws.com') {
                sh "kubectl get pods"
                sh "kubectl get svc"
                
             }
            }
        }
    }
    
    post {
    always {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

            def body = """
            <html>
            <body>
            <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
            </div>
            </body>
            </html>
            """

            emailext(
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'ashenjanath@gmail.com',
                from: 'jenkins@example.com',
                replyTo: 'jenkins@example.com',
                mimeType: 'text/html'
            )
        }
    }
}

}
