FROM jenkins/jenkins:jdk21


ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false


COPY install-plugins.sh /usr/local/bin/install-plugins.sh
USER root
RUN chmod +x /usr/local/bin/install-plugins.sh


COPY plugins.txt /usr/share/jenkins/ref/plugins.txt


USER jenkins
RUN install-plugins.sh /usr/share/jenkins/ref/plugins.txt


ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc_configs/jenkins.yaml