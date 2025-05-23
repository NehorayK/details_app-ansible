pipeline {
  agent any
  environment {
    PATH = "${env.HOME}/Library/Python/3.9/bin:/usr/local/bin:${env.PATH}"
    INVENTORY = 'inventory.ini'
    PLAYBOOK  = 'playbook.yml'
  }
  options {
    ansiColor('xterm')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Setup Environment') {
      steps {
        sh 'which docker'
        sh 'pip3 install --user ansible ansible-lint paramiko'
      }
    }
    stage('Lint Ansible') {
      steps { sh 'ansible-lint roles/details_app/tasks/main.yml' }
    }
    stage('Syntax Check') {
      steps { sh "ansible-playbook --syntax-check ${PLAYBOOK} -i ${INVENTORY}" }
    }
    stage('Dry Run') {
      steps { sh "ansible-playbook --check ${PLAYBOOK} -i ${INVENTORY}" }
    }
    stage('Build & Run Container') {
      steps {
        sh 'docker build -t ubuntu-systemd:22.04 -f Dockerfile .'
        sh 'docker rm -f appserver || true'
        sh """
          docker run -d --name appserver --privileged \
            -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
            --tmpfs /run:exec,mode=755 \
            --tmpfs /run/lock:mode=755 \
            --tmpfs /tmp:rw \
            -e container=docker ubuntu-systemd:22.04
        """
      }
    }
    stage('Deploy with Ansible') {
      steps { sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY}" }
    }
    stage('Integration Test') {
      steps { sh "docker exec appserver curl -fs http://localhost:8000/health" }
    }
    stage('Teardown') {
      steps { sh 'docker rm -f appserver' }
    }
  }
  post {
    success { echo '✅ Pipeline succeeded!' }
    failure { echo '❌ Pipeline failed.' }
    always {
      archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
    }
  }
}