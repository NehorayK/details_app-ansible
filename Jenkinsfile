pipeline {
  agent any

  environment {
    PATH                      = "${env.HOME}/Library/Python/3.9/bin:/usr/local/bin:${env.PATH}"
    INVENTORY                 = 'inventory.ini'
    PLAYBOOK                  = 'playbook.yml'
    ANSIBLE_HOST_KEY_CHECKING = 'False'
  }

  options {
    ansiColor('xterm')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup Environment') {
      steps {
        sh 'pip3 install --user ansible ansible-lint paramiko'
      }
    }

    stage('Lint Role') {
      steps {
        sh 'ansible-lint roles/details_app/tasks/main.yml'
      }
    }

    stage('Syntax Check') {
      steps {
        sh "ansible-playbook --syntax-check ${PLAYBOOK} -i ${INVENTORY} -c paramiko"
      }
    }

    stage('Deploy with Ansible') {
      steps {
        sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY} -c paramiko"
      }
    }
  }

  post {
    success { echo "✅ Pipeline succeeded!" }
    failure { echo "❌ Pipeline failed." }
  }
}