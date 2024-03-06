# FROM postgres:15.5

# RUN apt update -y && \
#     apt install iputils-ping -y && \
#     apt clean

# RUN ls /var/lib/postgresql
# COPY ./pgDataInit /var/lib/postgresql/data/

# ENV POSTGRES_PASSWORD=supersecret

# CMD [ "postgres" ]

# docker build -t psql-cluster .

# ============================================================

FROM debian:12

RUN apt update && apt install gnupg gnupg2 gnupg1 lsb-release wget curl sudo iputils-ping nano -y && apt clean
RUN bash -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN apt update &&  apt install postgresql-15 pgpool2 -y && apt clean

COPY pgpool.conf /tmp/pgpool2/
COPY pool_hba.conf /tmp/pgpool2/
RUN mv /tmp/pgpool2/pgpool.conf /etc/pgpool2
RUN mv /tmp/pgpool2/pool_hba.conf /etc/pgpool2

WORKDIR /etc/pgpool2

# docker build -t testdebian . 