pipeline {
    agent any

    // All variables are available at the different stages. Some names need to be specific 
    // Secret token for "netlify login details" stored safe in jenkins credentials as a secret
    environment {
        NETLIFY_SITE_ID = '97bb2c8f-b1c8-43b1-a904-ca0bc42cdea0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        // using the buildID for versioning. 
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {

        stage('Build') {
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
        }

        // For parallel stages
        stage('Tests') {
            parallel {

            stage('Unit Tests') {
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

            // Publish the JUnit test report to Jenkins server, no matter pipline fail or pass.
    
                post {
                    always {
                        junit 'jest-results/junit.xml'
                    }
                }
            }

        stage('E2E') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }

            // 1. Start application 2. Running test (-g = global, -s = single (single page application) , & = start in background(async?))
            // Sleep to allow for server to start up before testing
            steps {
                sh '''
                    serve -s build &
                    sleep 10
                    npx playwright test --reporter=line
                    ls -la playwright-report/ || echo "DIRECTORY MISSING"
                '''
                
            }

    
            // Publish html report for playwrigth
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: '', useWrapperFileDirectly: true])
                }
            }
        }

            }
    }

     stage('Deploy Staging & E2E') {
            agent {
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }

            // need to "instantiate" variable before setting it in steps later.
            environment {
                CI_ENVIRONMENT_URL = 'STAGING_URL_TO_BE_SET'
            }

            // CI_ENV only accessable from script when declared like this.
            steps {
                sh '''
                    netlify --version
                    echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                    netlify deploy --dir=build --json > deploy-output-json
                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy-output-json)
                    npx playwright test --reporter=line
                '''
            }

    
    // Publish html report for playwrigth
    post {
        always {
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
        }

     stage('Deploy prod & E2E') {
            agent {
                // playwrigth image contains node
                docker {
                    image 'my-playwright'
                    reuseNode true
                }
            }

            // Variables just for this stage, needed for testing production via playwrigth
            environment {
                CI_ENVIRONMENT_URL = 'https://storied-cat-a78302.netlify.app'
            }

            // Nelify deploy migth need time before deploy.
            steps {
                sh '''
                    node --version
                    netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod
                    npx playwright test --reporter=line
                '''
            }

    
    // Publish html report for playwrigth
    post {
        always {
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Prod E2E', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
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