FROM gradle:7.2.0-jdk11 AS build

WORKDIR /build

COPY --chown=gradle:gradle . .

RUN chown -R gradle /home/gradle/src

RUN gradle clean bootJar

FROM adoptopenjdk/openjdk11:latest as runtime

WORKDIR /app

RUN apt-get update && apt-get install -y wget \
    && DOCKERIZE_VERSION=v0.6.1 \
    && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY build/libs/*.jar app.jar

ENTRYPOINT ["dockerize", "-wait", "tcp://database:3306", "-timeout", "60s", "java", "-jar", "app.jar"]
