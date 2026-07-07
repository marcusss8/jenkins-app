pipeline {
    agent any

    stages {
       /*  stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        } */
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                echo "Test Stage"
                test -f build/index.html
                npm test
                '''
            }

        }

        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.61.0-noble'
                    reuseNode true
                    args ''
                }
            }

            // 1. Start application 2. Running test (-g = global, -s = , & = start in background(async?))
            // Sleep to allow for server to start up before testing
            steps {
                sh '''
                    npm install serve
                    node_modules/.bin/serve -s build &
                    sleep 10
                    npx playwright test
                '''
            }
        }
    }

    // Publish the JUnit test report to Jenkins server, no matter pipline fail or pass.
    post {
        always {
            junit 'test-results/junit.xml'
        }
    }
}

/*
            // Alternative way to test for file existance.
           steps {
                script {
                    if(fileExists('build/index.html')){
                        echo "The file does exists"
                    } else {
                        echo "The file does Not exist"
                    }
                }
            } */