FROM eclipse-temurin:17-jre as builder
WORKDIR application

# require "jar { enabled = false }" in "build.gradle" file
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} application.jar

# layering feature
RUN java -Djarmode=layertools -jar application.jar extract

# ------------------------------------------
FROM eclipse-temurin:17-jre
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]