pipeline {
    agent any
    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Version to deploy')
        string(name: 'DB_HOST', defaultValue: 'db.example.com', description: 'Postgres host for the app')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build & Package') {
            steps {
                sh 'python -m venv .venv'
                sh '. .venv/bin/activate; pip install -r requirements.txt'
                sh "tar -czf flask_app-${params.APP_VERSION}.tar.gz app.py config.py requirements.txt templates db"
                archiveArtifacts artifacts: "flask_app-${params.APP_VERSION}.tar.gz", fingerprint: true
            }
        }
        stage('Run Ansible Deploy') {
            agent { label 'jenkins-agent' }
            steps {
                // Copy artifact to agent and run ansible-playbook
                sh "mkdir -p /tmp/deploy && cp flask_app-${params.APP_VERSION}.tar.gz /tmp/deploy/"
                sh "ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -e 'app_version=${params.APP_VERSION} db_host=${params.DB_HOST}'"
            }
        }
    }
}
