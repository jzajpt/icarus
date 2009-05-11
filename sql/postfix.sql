drop table if exists postfix_alias;
create table postfix_alias (
  id       int not null auto_increment,
  address  varchar(255) not null,
  goto     text not null,
  domain   varchar(255) not null,
  created  datetime not null,
  modified datetime not null,
  active   tinyint(1) not null default '1',
  primary key(id)
) COMMENT='Postfix - Virtual Aliases';

drop table if exists postfix_domain;
create table postfix_domain (
  id          int not null auto_increment,
  domain      varchar(255) not null,
  description varchar(255) not null,
  aliases     int(10) not null,
  mailboxes   int(10) not null,
  maxquota    int(10) not null,
  backupmx    tinyint(1) not null,
  transport   varchar(255) not null default 'virtual:',
  created     datetime not null,
  modified    datetime not null,
  active      tinyint(1) not null default '1',
  primary key(id),
  unique key(domain)
) COMMENT='Postfix - Virtual Domains';

drop table if exists postfix_mailbox;
create table postfix_mailbox (
  id       int not null auto_increment,
  username varchar(255) not null,
  password varchar(255) not null,
  name     varchar(255) not null,
  maildir  varchar(255) not null,
  homedir  varchar(255) not null,
  quota    int(10) not null default '0',
  domain   varchar(255) not null,
  uid      int unsigned not null,
  gid      int unsigned not null,
  created  datetime not null,
  modified datetime not null,
  active   tinyint(1) not null default '1',
  primary key(id),
  unique key(username)
) COMMENT='Postfix - Virtual Mailboxes';
