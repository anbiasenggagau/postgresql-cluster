up:
	docker compose up -d && \
	cp init.sql ./PrimaryDatabase/init_sql && \
	{ while ! docker exec psql-1 pg_isready -U anbiasenggagau; do sleep 1; done; } && \
	cp pg_hba.conf ./PrimaryDatabase/pg_data/pg_hba.conf && \
	cp postgresql.conf ./PrimaryDatabase/pg_data/postgresql.conf && \
	docker exec -it psql-1 bash -c "psql -U anbiasenggagau -d postgres -f /docker-entrypoint-initdb.d/init.sql" && \
	docker restart psql-1 && \
	{ while ! docker exec psql-1 pg_isready -U anbiasenggagau; do sleep 1; done; } && \
	docker exec -it psql-2 bash -c "pg_basebackup -h psql-1 -p 5432 -U repuser --checkpoint=fast -D /var/lib/postgresql/backup -R --slot=replication_slot -C && \
	rm -r /var/lib/postgresql/data/* && \
	cp -Rf /var/lib/postgresql/backup/* /var/lib/postgresql/data/" && \
	docker restart psql-2 && \
	docker compose logs -f 

down:
	docker compose down -v && \
	rm -r ./SecondaryDatabase && \
	rm -r ./PrimaryDatabase

restart:
	make down && make up