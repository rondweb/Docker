# Use the official PostgreSQL image from the Docker Hub
FROM postgres:17.2-bullseye

LABEL maintainer="PostGIS Project - https://postgis.net" \
      org.opencontainers.image.description="PostGIS 3.4.3+dfsg-2.pgdg110+1 spatial database extension with PostgreSQL 17 bullseye" \
      org.opencontainers.image.source="https://github.com/postgis/docker-postgis"

ENV POSTGIS_MAJOR=3
ENV POSTGIS_VERSION=3.5.1+dfsg-1.pgdg110+1

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           ca-certificates \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
           postgresql-$PG_MAJOR-postgis-scripts \
      && rm -rf /var/lib/apt/lists/*

RUN apt-get update -qq && \
    apt-get install -y build-essential openssl pkg-config python-is-python3 git postgresql-server-dev-$PG_MAJOR
# Install dependencies required to build pgvector
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    clang \
    llvm \
    postgresql-server-dev-17

# Clone the pgvector repository, build and install the extension
RUN cd /tmp \
    && git clone --branch v0.8.0 https://github.com/pgvector/pgvector.git \
    && cd pgvector \
    && make \
    && make install \
    && cd / \
    && rm -rf /tmp/pgvector

RUN git clone --branch v0.5.0 https://github.com/pgvector/pgvector.git
WORKDIR /pgvector
RUN make && make install

WORKDIR /home/
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin

# Add a script to create the pgvector extension in the new database
COPY init.sql /docker-entrypoint-initdb.d/

# Ensure the correct permissions on the script
RUN chmod 755 /docker-entrypoint-initdb.d/init.sql

# Expose port 5432 to the outside world
EXPOSE 5432


# docker run -it -p 5532:5432 --name postgis -e POSTGRES_PASSWORD=Brequois305! rondweb/postgis:17.2