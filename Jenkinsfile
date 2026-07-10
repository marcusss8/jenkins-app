pipeline {
    agent any

    // All variables 
    // Secret token for "netlify login details" stored safe in jenkins credentials as a secret
    environment {
        NETLIFY_SITE_ID = '97bb2c8f-b1c8-43b1-a904-ca0bc42cdea0'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
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
                    echo 'Small test change'
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
        stage('Run Tests') {
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
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    args ''
                }
            }

            // 1. Start application 2. Running test (-g = global, -s = single (single page application) , & = start in background(async?))
            // Sleep to allow for server to start up before testing
            steps {
                sh '''
                    whoami          # prints the username you're running as
                    id              # prints UID, GID, and group memberships
                    ls -la          # shows the owner column for every file in the current folder
                    npm install serve
                    node_modules/.bin/serve -s build &
                    sleep 10
                    npx playwright test --reporter=line
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

        // Deploying to non-public "server" in order to test finished page before actuall deploy
        // By removing "---prod" from netlify deploy
        stage('Deploy staging'){
        agent{
             docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
        }

        steps {
            sh '''
                npm install netlify-cli@20.1.1
                node_modules/.bin/netlify --version
                echo "Deploying to staging. Site ID: $NETLIFY_SITE_ID"
                node_modules/.bin/netlify status
                node_modules/.bin/netlify deploy --dir=build
            '''
        }
    }
    
     stage('Approval'){
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    input message: 'Ready to deploy?', ok: 'Yes, I am sure I want to deploy'
                }
                    
            }
        }


        
    stage('Deploy prod'){
        agent{
             docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
        }

        steps {
            sh '''
                npm install netlify-cli@20.1.1
                node_modules/.bin/netlify --version
                echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                node_modules/.bin/netlify status
                node_modules/.bin/netlify deploy --dir=build --prod
            '''
        }
    }

     stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    args ''
                }
            }

            // Variables just for this stage, needed for testing production via playwrigth
            environment {
                CI_ENVIRONMENT_URL = 'https://storied-cat-a78302.netlify.app'
            }

            steps {
                sh '''
                    npx playwright test --reporter=line
                '''
            }

    
    // Publish html report for playwrigth
    post {
        always {
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E', reportTitles: '', useWrapperFileDirectly: true])
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