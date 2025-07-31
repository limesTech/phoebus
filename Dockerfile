FROM maven:3.9 AS build
RUN apt update & apt -y install git
RUN git clone -b master --single-branch https://gitlab.rlp.net/tibolch/phoebus-origin-mirror.git
RUN mvn -q -DskipTests -pl phoebus-product clean install 

FROM openjdk:21-slim-buster as phoebus
COPY --from=build /phoebus/phoebus-product/target/product-*.jar /phoebus/phoebus.jar
COPY --from=build /phoebus/phoebus-product/target/lib /phoebus/lib
WORKDIR /phoebus
ENTRYPOINT ["java", "-jar", "/phoebus/phoebus.jar" , "-settings" , "${SETTINGS_FILE}"]
CMD ["-list"]

