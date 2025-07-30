pipeline {
    agent any
    environment {
        REGISTRY = "registry-02.oss.net.bd"
        dockerRegistryCredential = 'registry-02.oss.net.bd'
        dockerImage = ''
        DOCKER_REGISTRY_URL = "https://${REGISTRY}"
        IMAGE_CREATED_BY = "jenkins"
        PROJECT_NAME = "bbp-app-dev"
        HARBOR_PROJECT = "bbp-app-dev"
        NAMESPACE = "bbp-dev"

        GIT_TAG = sh(returnStdout: true, script: '''
            echo $(git describe --tags)
        ''').trim()

        DEPLOYMENT_ENV_VERSION = "$NAMESPACE"
        DEPLOYMENT_ENV = "dev"
        PROJECT_LOCATION = "${JENKINS_DATA_LOCATION}/workspace/${JOB_NAME}"
        IMAGE_VERSION = "${BUILD_NUMBER}-${IMAGE_CREATED_BY}-${DEPLOYMENT_ENV_VERSION}"
        DOCKER_TAG = "${REGISTRY}/${HARBOR_PROJECT}/${PROJECT_NAME}:${IMAGE_VERSION}"
        DEPLOYMENT_DIRECTORY = "./"
        DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1295788881727459350/u6ZMfF9Zfs0fL1OwdYuTaGFayOYoUukfhjSwnGVDJyOakzronY6y9EAoHZc1O6bBdXPC"
        

    }
    
    post {
        always {
            echo 'Discord Notification.'
            discordSend description: "$PROJECT_NAME-$DEPLOYMENT_ENV", scmWebUrl: 'https://codelab.ba-systems.com/bbp/bbp-frontend.git', showChangeset: true, 
            footer: "message: ${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}", 
            webhookURL: 'https://discord.com/api/webhooks/1295788881727459350/u6ZMfF9Zfs0fL1OwdYuTaGFayOYoUukfhjSwnGVDJyOakzronY6y9EAoHZc1O6bBdXPC'
            }   
        }

    stages {
        stage('Init') {
            steps {
                script {
                    COMMIT_ID = sh(
                        script: "git log -1 --pretty=format:'%H'",
                        returnStdout: true
                    ).trim()
                    echo "Commit ID: $COMMIT_ID"
                }
            }
        }

        stage('Building Docker image') { 
            steps { 
                script { 
                    dockerImage = docker.build(DOCKER_TAG, "-f ./Dockerfile .")
                }
                sh '''
                docker images | grep ${PROJECT_NAME}
                '''
            } 
        }

        stage('Security Scan') {
            steps {
                script {
                    def sbomPath = "trivy-report.json"
                    def webhookUrl = "https://discord.com/api/webhooks/1295788881727459350/u6ZMfF9Zfs0fL1OwdYuTaGFayOYoUukfhjSwnGVDJyOakzronY6y9EAoHZc1O6bBdXPC" // <-- paste your full URL here

                    // Generate CycloneDX SBOM
                    sh """
                        trivy image --format cyclonedx --output ${sbomPath} ${DOCKER_TAG}
                    """

                    // Trivy scan with exit-code logic
                    def scanResult = sh(
                        script: "trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_TAG}",
                        returnStatus: true
                    )

                    def message = scanResult != 0 ?
                        "⚠ Trivy scan failed for image ${DOCKER_TAG}. High or critical vulnerabilities found." :
                        "✅ Trivy scan succeeded for image ${DOCKER_TAG}. No critical vulnerabilities found."

                    // Escape double quotes and send Discord notification
                    def payload = """{"content": "${message.replace('"', '\\"')}"}"""

                    sh """
                        curl -H "Content-Type: application/json" \
                            -d '${payload}' \
                            ${webhookUrl}
                    """
                }
            }
        }




        stage('Dependency Track Publisher') {
            steps {
                withCredentials([string(credentialsId: 'DR-Tracker2', variable: 'API_KEY')]) {
                    dependencyTrackPublisher artifact: 'trivy-report.json', 
                                            autoCreateProjects: true, 
                                            projectName: 'BBP_APP', 
                                            projectVersion: '1.0', 
                                            dependencyTrackApiKey: API_KEY, 
                                            projectId: '02caf121-d662-4178-b662-f63b674adc72', 
                                            synchronous: true
                }
            }
        }


        stage('Push Docker image') {
            steps {
                script {
                    docker.withRegistry("$DOCKER_REGISTRY_URL", dockerRegistryCredential) {
                        dockerImage.push()
                    }
                    sh "docker images | grep ${PROJECT_NAME}"
                }
            }
        }

        stage('Delete Image After Upload to Registry') {
            steps {
                echo "Cleaning local Docker registry: ${DOCKER_TAG} image"
                sh "docker rmi ${DOCKER_TAG}"
            }
        }

        stage('Trigger Manifest Update') {
            steps {
                echo "Triggering update_manifest job"
                build job: 'bbp_frontend-manifest', parameters: [
                    string(name: 'DOCKER_TAG', value: DOCKER_TAG)
                ]
            }
        }
    }
}