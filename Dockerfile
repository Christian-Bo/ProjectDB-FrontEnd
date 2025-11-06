# ====== Etapa 1: Build (genera el WAR con Maven) ======
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
# Compila sin tests y empaqueta el WAR
RUN mvn -q -DskipTests package

# ====== Etapa 2: Runtime (Tomcat 10) ======
FROM tomcat:10.1-jdk17-temurin
WORKDIR /usr/local/tomcat

# Limpia apps por defecto (ROOT, docs, etc.)
RUN rm -rf webapps/*

# Copia tu WAR como ROOT.war para servir en "/"
COPY --from=build /src/target/*.war webapps/ROOT.war

# Memoria razonable para plan free
ENV CATALINA_OPTS="-Xms256m -Xmx512m"

EXPOSE 8080
CMD ["catalina.sh","run"]
