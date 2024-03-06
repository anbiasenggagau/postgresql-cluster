do
$$
begin
	if exists(
		select * from pg_catalog.pg_roles p
		where p.rolname = 'repuser') then	
	raise notice 'role already exist';
	else
	create user repuser REPLICATION LOGIN encrypted password 'supersecret';
	end if;
end
$$ LANGUAGE plpgsql;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary NUMERIC(10, 2)
);
