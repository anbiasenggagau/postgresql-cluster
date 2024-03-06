# Introduction
postgresql has built in replica, in order to use this feature
you need multiple hosts that run postgresql service.

# Steps to build the services
1. Build infrastructure using ``docker compose up``


## On primary server
2. configure postgresql.conf to listen to all addresses
3. configure pg_hba.conf to define egress and ingress connection
4. create new user for replication purpose
5. start/restart postgresql using this config
	you can achieve this by running command  
```
pg_ctl -D /var/lib/postgresql/data/
```
where the directory path is all of your postgresql config

## On seconday server
6. Make sure primary server is already running by using ping or ``pg_isready`` command
7. run this command
```
pg_basebackup -h psql-1 -p 5432 -U repuser --checkpoint=fast -D /var/lib/postgresql/backup -R --slot=replication_slot -C
```
to generate postgresql config as replica instance of primary instance
	all config files will be stored in ``/var/lib/postgresql/backup``

8. run
```
pg_ctl -D /var/lib/postgresql/backup/
```
to start the replica instance
	or overwrite existing config server in 

``/var/lib/postgresql/data/`` by use command
```
rm -r /var/lib/postgresql/data/* && \
cp -Rf /var/lib/postgresql/backup/* /var/lib/postgresql/data/
```
then start the service by using command  
```
pg_ctl -D /var/lib/postgresql/data/
```

9. All data that is written on primary server will be replicated asynchronously into secondary server
10. secondary server will run on read only mode, while primary server will run on read/write mode

# Commands

## Build infrastructure
> execute from local machine

```
docker compose up
```

## Copy postgresql config file to postgresql directory
> execute from psql-1

```
cp pg_hba.conf ./PrimaryDatabase/pg_data/pg_hba.conf &&
cp postgresql.conf ./PrimaryDatabase/pg_data/postgresql.conf
```

## Create role repuser with password
> execute from psql-1

```
psql -U anbiasenggagau -d postgres -f /docker-entrypoint-initdb.d/init.sql
```

## restart primary server
> execute from local machine

```
docker restart psql-1
```

## Generate Stream Replication config from host of psql-1
> execute from psql-2

```
pg_basebackup -h psql-1 -p 5432 -U repuser --checkpoint=fast -D /var/lib/postgresql/backup -R --slot=replication_slot -C
```

## overwrite existing database config
> execute from psql-2

```
rm -r /var/lib/postgresql/data/* &&
cp -Rf /var/lib/postgresql/backup/* /var/lib/postgresql/data/
```

## restart container of postgre service
> execute from local machine

```
docker restart psql-2
```

# Notes

all command already capsulated in Makefile