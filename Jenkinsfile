pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' 
            }
        }   
      stage('unit Tests') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
        }
      stage('SonarQ') {
            steps {
              withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                sh "mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                    -Dsonar.projectKey=numaric-application \
                    -Dsonar.projectName='numaric-application' \
                    -Dsonar.host.url=http://192.168.64.15:9000 \
                    -Dsonar.token=${SONAR_TOKEN}"
              }
            }
        } 
      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh "printenv"
                sh 'docker build -t spolla786/numeric-app:${GIT_COMMIT} .'
                sh 'docker push spolla786/numeric-app:${GIT_COMMIT}'
                // testing
              }
            }
        }
      stage('Kubernetes Deployment - Dev') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#spolla786/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh 'kubectl apply -f k8s_deployment_service.yaml'
                // testing
              }
            }
        }
    }
}