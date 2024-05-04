FROM postgis/postgis:16-3.4

LABEL maintainer="Constantine Malykhin <constantine.malykhin@gmail.com>"

RUN apt-get update && \
    apt-get install -y postgresql-16-h3