drop table if exists domains;
create table domains (
	id              int auto_increment,
	name            varchar(255) not null,
	master          varchar(128) default null,
	last_check      int default null,
	type            varchar(6) not null,
	notified_serial int default null, 
	account         varchar(40) default null,
	primary key(id)
);

create unique index name_index on domains(name);

drop table if exists records;
create table records (
	id              int auto_increment,
	domain_id       int default null,
	name            varchar(255) default null,
	type            varchar(6) default null,
	content         varchar(255) default null,
	ttl             int default null,
	prio            int default null,
	change_date     int default null,
	primary key(id)
);

create index rec_name_index on records(name);
create index nametype_index on records(name,type);
create index domain_id on records(domain_id);

drop table if exists supermasters;
create table supermasters (
	ip         varchar(25) not null, 
	nameserver varchar(255) not null, 
	account    varchar(40) default null
);