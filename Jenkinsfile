pipeline {
  agent any

  environment {
    // ensure pip3 installs go into your PATH
    PATH                       = "${env.HOME}/Library/Python/3.9/bin:/usr/local/bin:${env.PATH}"
    INVENTORY                  = 'inventory.ini'
    PLAYBOOK                   = 'playbook.yml'
    // force Ansible to use Paramiko so sshpass isn’t required
    ANSIBLE_HOST_KEY_CHECKING  = 'False'
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
        // install Ansible, lint tool, Paramiko transport into your local user
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

    stage('Dry Run') {
      steps {
        sh "ansible-playbook --check ${PLAYBOOK} -i ${INVENTORY} -c paramiko"
      }
    }
  }

  post {
    success { echo '✅ Pipeline succeeded!' }
    failure { echo '❌ Pipeline failed.' }
    always  {
      archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
    }
  }
}