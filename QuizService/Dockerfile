
FROM maven:3.9-sapmachine-21 AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

FROM tomcat:11.0.0-jdk21
COPY --from=build /home/app/target/QuizService-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

ENV SERVER_PORT=8080
ENV MONGO_HOST=QuizServiceDBMongo
ENV MONGO_PORT=27017
ENV MONGO_DB=QuizServiceService
ENV EUREKA_HOST=EurekaRegistry


