FROM postgres:15-bullseye

LABEL maintainer="Constantine Malykhin <constantine.malykhin@gmail.com>"

ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.4.0+dfsg-1.pgdg110+1

# Install required packages in a single RUN instruction
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
    libpq-dev \
    postgresql-server-dev-all \
    apt-transport-https \
    gnupg \
    software-properties-common \
    wget \
    pgxnclient && \
    rm -rf /var/lib/apt/lists/*

# Install cmake 3.20+
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - && \
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' && \
    apt-get update && \
    apt-get install cmake -y

# Install Uber's h3 extension
RUN pgxn install 'h3=4.1.3'
