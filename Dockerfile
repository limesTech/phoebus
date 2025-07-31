FROM maven:eclipse-temurin AS build
RUN apt-get update && apt-get -y install git python3
RUN git clone -b master --single-branch https://gitlab.rlp.net/tibolch/phoebus-origin-mirror.git
WORKDIR /phoebus-origin-mirror
RUN mvn verify -f dependencies/pom.xml
RUN mvn -q -DskipTests install
RUN cd phoebus-product && python3 create_settings_template.py 


FROM eclipse-temurin:21-jre-alpine AS phoebus
RUN apk update && apk add python3
COPY --from=build /phoebus-origin-mirror/phoebus-product/target/product-*.jar /phoebus/phoebus.jar
COPY --from=build /phoebus-origin-mirror/phoebus-product/target/lib /phoebus/lib
COPY --from=build /phoebus-origin-mirror/phoebus-product/settings_template.ini /phoebus/settings.ini
WORKDIR /phoebus
# ENTRYPOINT ["java", "-jar", "/phoebus/phoebus.jar" , "-settings" , "./lib/settings.ini"]
# CMD ["-list"]

