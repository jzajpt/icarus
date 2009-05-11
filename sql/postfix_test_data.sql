delete from postfix_domain;
alter table postfix_domain auto_increment = 1;
delete from postfix_mailbox;
alter table postfix_mailbox auto_increment = 1;
delete from postfix_alias;
alter table postfix_alias auto_increment = 1;
	
insert into postfix_domain(domain, description, created, modified) values
  ('blueberry.cz', 'blueberry.cz test data', now(), now()),
	('jzajpt.cz', 'jzajpt.cz test data', now(), now());

insert into postfix_mailbox(username, password, name, maildir, domain, created, modified) values
  ('jzajpt@blueberry.cz', '', 'Jiri Zajpt', 'blueberry.cz/jzajpt/', 'blueberry.cz', now(), now()),
  ('johnny@blueberry.cz', '', 'Johnny', 'blueberry.cz/johnny/', 'blueberry.cz', now(), now());

insert into postfix_alias(address, goto, domain, created, modified) values
  ('jzajpt@blueberry.cz', 'jzajpt@blueberry.cz', 'blueberry.cz', now(), now());

