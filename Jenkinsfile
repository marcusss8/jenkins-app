pipeline {
    agent any

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
        stage('Test') {
            /* steps {
                sh 'echo "Test Stage"' 
                sh 'test -f build/index.html' // Check for existance of a certain file
            } */
            steps {
                script {
                    if(fileExists('build/index.html')){
                        echo "The file does exists"
                    } else {
                        echo "The file does Not exist"
                    }
                }
            }

            
        }
    }
}
