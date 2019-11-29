FROM jenkins/jenkins:2.206

MAINTAINER Stanislav Davydov

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY groovy/* /usr/share/jenkins/ref/init.groovy.d/

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt


USER root

RUN curl -o /tmp/filebeat-7.3.1-amd64.deb https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.1-amd64.deb && \
    dpkg -i /tmp/filebeat-7.3.1-amd64.deb &&  apt-get install

COPY filebeat.yml /etc/filebeat/filebeat.yml

COPY ["entrypoint.sh", "/"]

COPY ansible-ubuntu-xenial.list /etc/apt/sources.list.d/ansible-ubuntu-xenial.list

#RUN apt update
#RUN apt-get install -y apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common lsb_release
#RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ansible-ubuntu-$(lsb_release -cs).list
#RUN add-apt-repository ppa:ansible/ansible
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt update
RUN apt install -y ansible

RUN chmod +x /entrypoint.sh
RUN chmod 644 /etc/filebeat/filebeat.yml

ENTRYPOINT ["/bin/bash","-c","./entrypoint.sh"]
