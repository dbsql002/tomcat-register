# Redis를 사용하기 위한 Jedis 라이브러리 설치 도커 파일
FROM alpine:latest as builder
  
RUN apk update && \
apk add --no-cache openjdk8 wget tar unzip

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV CATALINA_HOME /usr/local/tomcat9.0
ENV TOMCAT_VERSION 9.0.89

RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz && \
mkdir -p $CATALINA_HOME && \
tar -xvf apache-tomcat-9.0.89.tar.gz -C $CATALINA_HOME --strip-components=1 && \
rm apache-tomcat-9.0.89.tar.gz && \
wget https://dlm.mariadb.com/3752081/Connectors/java/connector-java-3.3.3/mariadb-java-client-3.3.3.jar && \
mv mariadb-java-client-3.3.3.jar $CATALINA_HOME/lib/ && \
rm -rf $CATALINA_HOME/webapps/* && \
mkdir -p $CATALINA_HOME/webapps/ROOT && \
# Redis
wget https://github.com/ran-jit/tomcat-cluster-redis-session-manager/releases/download/2.0.4/tomcat-cluster-redis-session-manager.zip && \
unzip tomcat-cluster-redis-session-manager.zip -d $CATALINA_HOME && \
mv $CATALINA_HOME/tomcat-cluster-redis-session-manager/lib/* $CATALINA_HOME/lib/ && \
mv $CATALINA_HOME/tomcat-cluster-redis-session-manager/conf/* $CATALINA_HOME/conf/ && \
# Jedis
wget https://repo1.maven.org/maven2/redis/clients/jedis/3.7.1/jedis-3.7.1.jar && \
cp jedis-3.7.1.jar $JAVA_HOME/lib/ && \
mv jedis-3.7.1.jar $CATALINA_HOME/lib/

# Redis properties and other configurations
COPY ./index.jsp $CATALINA_HOME/webapps/ROOT/                            
COPY ./registerAction.jsp $CATALINA_HOME/webapps/ROOT/


FROM alpine:latest

RUN apk add --no-cache openjdk8-jre-base && \
rm -rf /var/cache/apk/*

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV CATALINA_HOME /usr/local/tomcat9.0
ENV PATH $JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH
ENV CLASSPATH .:$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/lib/jsp-api.jar:$CATALINA_HOME/lib/servlet-api.jar:$CATALINA_HOME/lib/mariadb-java-client-3.3.3.jar:$CATALINA_HOME/lib/jedis-3.7.1.jar:$CATALINA_HOME/lib/tomcat-cluster-redis-session-manager-2.0.4.jar

COPY --from=builder $CATALINA_HOME $CATALINA_HOME

EXPOSE 8080

CMD ["catalina.sh", "run"]
