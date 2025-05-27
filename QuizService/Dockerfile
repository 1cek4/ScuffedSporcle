FROM maven:3.9-sapmachine-21 AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

FROM eclipse-temurin:21-jre
COPY --from=build /home/app/target/QuizService-0.0.1-SNAPSHOT.jar /app/QuizService.jar

ENV SERVER_PORT=8080
ENV MONGO_HOST=QuizServiceDBMongo
ENV MONGO_PORT=27017
ENV MONGO_DB=QuizServiceService
ENV EUREKA_HOST=EurekaRegistry

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/QuizService.jar"]


