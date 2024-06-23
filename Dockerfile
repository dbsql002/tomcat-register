# 빌드 스테이지
FROM alpine:latest as builder
# 필수 패키지 설치 및 Tomcat 다운로드
RUN apk add --no-cache openjdk8 curl tar && \
    curl -O https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.89/bin/apache-tomcat-9.0.89.tar.gz && \
    mkdir -p /usr/local/tomcat && \
    tar -xzf apache-tomcat-9.0.89.tar.gz -C /usr/local/tomcat --strip-components=1 && \
    curl -O https://downloads.mariadb.com/Connectors/java/connector-java-3.0.0/mariadb-java-client-3.0.0.jar && \
    mv mariadb-java-client-3.0.0.jar /usr/local/tomcat/lib/ && \
    rm apache-tomcat-9.0.89.tar.gz && \
    rm -rf /usr/local/tomcat/webapps/examples \
           /usr/local/tomcat/webapps/docs \
           /usr/local/tomcat/webapps/manager \
           /usr/local/tomcat/webapps/host-manager && \
    chmod +x /usr/local/tomcat/bin/*.sh

# JSP 파일 복사
COPY index.jsp /usr/local/tomcat/webapps/ROOT/
COPY registerAction.jsp /usr/local/tomcat/webapps/ROOT/

# 최종 단계
FROM alpine:latest

# 필수 패키지 설치
RUN apk add --no-cache openjdk8-jre-base && \
    rm -rf /var/cache/apk/*

# 환경 변수 설정
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH

# 빌드 스테이지에서 Tomcat 파일 복사 (lib 디렉토리 포함)
COPY --from=builder /usr/local/tomcat /usr/local/tomcat

# 포트 노출
EXPOSE 8080

# Tomcat 실행
CMD ["catalina.sh", "run"]
