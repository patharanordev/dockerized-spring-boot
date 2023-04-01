# Dockerized Spring Boot

## Learning Step

> **Ref.** https://docs.spring.io/spring-boot/docs/current/reference/html/documentation.html#documentation

## Installation

> Installation (MacOS): Install Java v17, grade, …
>
> Ref. https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html#getting-started.introducing-spring-boot

All you need:

```sh
brew tap spring-io/tap
brew install spring-boot
brew install gradle
brew install maven
```

## Preparation

### Initial project

Create Simple project via Spring [initializr](https://start.spring.io/).

Assume:

- project name/artifact : `demo-spring-boot`
- `Gradle - groovy` base
- Spring boot `v2.7.10`
- Dependencies:
  - Spring rest doc
  - Rest repositories
  - Spring boot dev tools
  - Spring web

### Modify script

for `RESTful`:

```java
package com.patharanor.demospringboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class DemoSpringBootApplication {

    @RequestMapping("/")
    String home() {
        return "Hello World";
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoSpringBootApplication.class, args);
    }

}
```

## Usage

### Development with LiveReload

You can't have the `bootRun` task running with the continuous option (if your app stays alive indefinitely). But there is a hack by Stefan Crain :

To get it to live reload you need to have 2 terminals open.

The first terminal run :

```sh
gradle build --continuous

Starting a Gradle Daemon (subsequent builds will be faster)

BUILD SUCCESSFUL in 5s
6 actionable tasks: 6 executed

Waiting for changes to input files... (ctrl-d to exit)
<-------------> 0% WAITING
> IDLE
> IDLE
```

build `--continuous` will keep satisfying the initial build request until stopped.

> For run in background, you can run `gradle build --continuous --quiet & 2>1 >/dev/null` to handle in the background, but you would miss the important build warnings/errors. gradle --stop to stop watching.

The second terminal run, `bootRun` starts with `spring-boot-devtools` on classpath, which will detect changes and restart application :

```sh
gradle bootRun

> Task :bootRun
19:52:18.150 [Thread-0] DEBUG org.springframework.boot.devtools.restart.classloader.RestartClassLoader - Created RestartClassLoader org.springframework.boot.devtools.restart.classloader.RestartClassLoader@577c9290

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::               (v2.7.10)

YYYY-MM-DD 19:52:18.297  INFO 39068 --- [  restartedMain] c.p.d.DemoSpringBootApplication          : Starting DemoSpringBootApplication using Java 17.0.6 on PatharaNor.local with PID 39068 (/Users/Pathara.No/projects/test/demo-spring-boot/build/classes/java/main started by patharanor in /Users/Pathara.No/projects/test/demo-spring-boot)
YYYY-MM-DD 19:52:18.298  INFO 39068 --- [  restartedMain] c.p.d.DemoSpringBootApplication          : No active profile set, falling back to 1 default profile: "default"
YYYY-MM-DD 19:52:18.322  INFO 39068 --- [  restartedMain] .e.DevToolsPropertyDefaultsPostProcessor : Devtools property defaults active! Set 'spring.devtools.add-properties' to 'false' to disable
YYYY-MM-DD 19:52:18.322  INFO 39068 --- [  restartedMain] .e.DevToolsPropertyDefaultsPostProcessor : For additional web related logging consider setting the 'logging.level.web' property to 'DEBUG'
YYYY-MM-DD 19:52:18.763  INFO 39068 --- [  restartedMain] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
YYYY-MM-DD 19:52:18.768  INFO 39068 --- [  restartedMain] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
YYYY-MM-DD 19:52:18.768  INFO 39068 --- [  restartedMain] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.73]
YYYY-MM-DD 19:52:18.791  INFO 39068 --- [  restartedMain] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
YYYY-MM-DD 19:52:18.791  INFO 39068 --- [  restartedMain] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 469 ms
YYYY-MM-DD 19:52:19.130  INFO 39068 --- [  restartedMain] o.s.b.d.a.OptionalLiveReloadServer       : LiveReload server is running on port 35729
YYYY-MM-DD 19:52:19.142  INFO 39068 --- [  restartedMain] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
YYYY-MM-DD 19:52:19.147  INFO 39068 --- [  restartedMain] c.p.d.DemoSpringBootApplication          : Started DemoSpringBootApplication in 0.992 seconds (JVM running for 1.204)
<==========---> 80% EXECUTING [1m 23s]
> :bootRun
```

> **IMPORTANT**: After built into `*.jar`, you cannot use live reload feature.

Let’s try `http://localhost:8080/` on browser.

## Build executable file

Build it to `*.jar` by `gradle`:

```sh
./gradlew build
```

Run the `*.jar`:

```sh
java -jar build/libs/demo-spring-boot-0.0.1-SNAPSHOT.jar
```

Let’s try http://localhost:8080/ on browser.

## Dockerize

Create “Dockerfile” then adding :

```dockerfile
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
```

### Build & Run container

Build container:

```sh
docker build -t demo-spring-boot .
```

then run it:

```sh
docker run -p 8080:8080 demo-spring-boot
```

Let’s try http://localhost:8080/ on browser.
