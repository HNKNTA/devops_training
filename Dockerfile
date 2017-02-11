FROM tomcat:8.5

ARG project_name=task4
ARG version=1.0-stable
ARG war_path=/usr/local/tomcat/webapps
ARG nexus_url=http://172.17.0.1:8081/nexus/content/repositories/training/${project_name}/

RUN wget -P ${war_path} ${nexus_url}${version}/${project_name}.war


