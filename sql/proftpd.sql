drop table if exists proftpd;
create table proftpd(
	id          int(11)          not null auto_increment,
	username    varchar(30)      not null,
	password    varchar(50)      not null,
	uid         int(5) unsigned  default '10000' not null,
	gid         int(5) unsigned  default '10000' not null,
	ftpdir      varchar(255)     not null,
	homedir     varchar(255)     not null,
	count       int(11) unsigned default 0,
	valid_until datetime,
	primary key(id),
	unique key(username)
);

drop table if exists proftpd_accesslog;
create table proftpd_accesslog(
	id       int unsigned not null auto_increment,
	username varchar(30)  not null,
	at       datetime     not null,
	ip       varchar(20),
	primary key(id)
);
