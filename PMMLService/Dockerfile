FROM tomcat
RUN rm -fr /opt/tomcat/webapps/*
COPY target/PMMLEvalService-0.0.1.war /opt/tomcat/webapps/ROOT.war
RUN mkdir logs

ENTRYPOINT /opt/tomcat/bin/catalina.sh run

