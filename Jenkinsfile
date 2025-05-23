pipeline {
  agent {
    docker {
      image 'python:3.10'
      // mount Docker socket so we can start containers
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  // make sure Jenkins picks up docker CLI from /usr/local/bin
  environment {
    PATH = "/usr/local/bin:${env.PATH}"
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
      steps {
        checkout scm
      }
    }
    stage('Setup Environment') {
      steps {
        sh 'pip install --quiet ansible ansible-lint'
        sh 'ansible --version'
      }
    }
    stage('Lint Ansible') {
      steps {
        sh 'ansible-lint roles/details_app/tasks/main.yml'
      }
    }
    stage('Syntax Check') {
      steps {
        sh "ansible-playbook --syntax-check ${PLAYBOOK} -i ${INVENTORY}"
      }
    }
    stage('Dry Run') {
      steps {
        sh "ansible-playbook --check ${PLAYBOOK} -i ${INVENTORY}"
      }
    }
    stage('Build Systemd Image & Run Container') {
      steps {
        sh 'docker build -t ubuntu-systemd:22.04 -f Dockerfile .'
        sh '''
          docker rm -f appserver || true
          docker run -d --name appserver --privileged \
            -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
            --tmpfs /run:exec,mode=755 \
            --tmpfs /run/lock:mode=755 \
            --tmpfs /tmp:rw \
            -e container=docker ubuntu-systemd:22.04
        '''
      }
    }
    stage('Deploy with Ansible') {
      steps {
        sh "ansible-playbook ${PLAYBOOK} -i ${INVENTORY}"
      }
    }
    stage('Integration Test') {
      steps {
        // verifies the Flask app health endpoint inside the container
        sh "docker exec appserver curl -fs http://localhost:8000/health"
      }
    }
    stage('Tear Down') {
      steps {
        sh 'docker rm -f appserver'
      }
    }
  }
  post {
    success {
      echo '✅ Pipeline succeeded!'
    }
    failure {
      echo '❌ Pipeline failed.'
    }
    always {
      // optional: archive any logs or artifacts
      archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
    }
  }
}