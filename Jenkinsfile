pipeline {
    agent any

    tools {
        jdk 'jdk21'
        nodejs 'node23'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage("Clean Workspace") {
            steps {
                cleanWs()
            }
        }

        stage("Git Checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/prashanty3/zomato_clone.git'
            }
        }

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=zomato \
                        -Dsonar.projectKey=zomato
                    '''
                }
            }
        }

        stage("Code Quality Gate") {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true, credentialsId: 'Sonar-token'
                }
            }
        }

        stage("Install NPM Dependencies") {
            steps {
                sh "npm install"
            }
        }

        stage("Build React App") {
            steps {
                sh "npm run build"
            }
        }

<<<<<<< HEAD
=======
        // stage("OWASP Dependency Scan") {
        //     steps {
        //         // Update vulnerability DB
        //         dependencyCheck additionalArguments: '--updateonly --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'

        //         // Perform scan
        //         dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit --format XML --out reports/', odcInstallation: 'DP-Check'

        //         // Publish report
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }

>>>>>>> 6fe22c2 (change in package.json, Dockerfile, Jenkinsfile)
        stage("Trivy File Scan") {
            steps {
                sh "trivy fs . > trivynew.txt"
            }
        }

        stage("Build Docker Image") {
            steps {
                script {
                    // Stop and remove existing container
                    sh '''
                        if docker ps -a --format "{{.Names}}" | grep -q "zomato"; then
                            docker stop zomato || true
                            docker rm zomato || true
                        fi
                    '''

                    // Remove old image
                    sh '''
                        if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "sonalisinhawipro/zomato:latest"; then
                            docker rmi sonalisinhawipro/zomato:latest || true
                        fi
                    '''

                    // Build new image (production-ready, serving from `dist/`)
                    sh "docker build -t sonalisinhawipro/zomato:latest ."
                }
            }
        }

        stage("Tag & Push to DockerHub") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker') {
                        sh "docker push sonalisinhawipro/zomato:latest"
                    }
                }
            }
        }

        stage("Docker Scout Analysis") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh 'docker-scout quickview sonalisinhawipro/zomato:latest'
                        sh 'docker-scout cves sonalisinhawipro/zomato:latest'
                        sh 'docker-scout recommendations sonalisinhawipro/zomato:latest'
                    }
                }
            }
        }

        stage("Deploy to Container") {
            steps {
                sh 'docker run -d --name zomato -p 3000:3000 sonalisinhawipro/zomato:latest'
            }
        }
    }

    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: """
                    <html>
                    <body>
                        <div style="background-color: #FFA07A; padding: 10px;">
                            <p style="color: white;"><b>Project:</b> ${env.JOB_NAME}</p>
                        </div>
                        <div style="background-color: #90EE90; padding: 10px;">
                            <p style="color: white;"><b>Build Number:</b> ${env.BUILD_NUMBER}</p>
                        </div>
                        <div style="background-color: #87CEEB; padding: 10px;">
                            <p style="color: white;"><b>URL:</b> ${env.BUILD_URL}</p>
                        </div>
                    </body>
                    </html>
                """,
                to: 'sonalisinhawipro@gmail.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy.txt'
        }
    }
}
