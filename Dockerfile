FROM maven:3.9 AS build
RUN apt update & apt -y install git python3.12-full 
RUN git clone -b master --single-branch https://gitlab.rlp.net/tibolch/phoebus-origin-mirror.git
WORKDIR /phoebus-origin-mirror
RUN mvn clean verify -f dependencies/pom.xml
RUN mvn -q -DskipTests clean install
RUN python3 phoebus-product/create_settings_template.py


FROM openjdk:21-slim-buster AS phoebus
RUN apt update && apt -y install python3.12-full
COPY --from=build /phoebus-origin-mirror/phoebus-product/target/product-*.jar /phoebus/phoebus.jar
COPY --from=build /phoebus-origin-mirror/phoebus-product/target/lib /phoebus/lib
WORKDIR /phoebus
ENTRYPOINT ["java", "-jar", "/phoebus/phoebus.jar" , "-settings" , "lib/settings.ini"]
CMD ["-list"]

