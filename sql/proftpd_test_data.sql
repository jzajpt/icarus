delete from proftpd;
alter table proftpd auto_increment = 1;
	
insert into proftpd(username, password, ftpdir, homedir) values
  ('blueberry.cz', '{sha}rv2KU8XLt25DQ3Y92aEGTxji2nM=', '/home/hosting/blueberry.cz/web/', '/home/hosting/blueberry.cz/web/'),
  ('jzajpt.cz', '{sha}KUtnRnKk4CSQ0qubIrJUjZvqy3o=', '/home/hosting/jzajpt.cz/web/', '/home/hosting/jzajpt.cz/web/');
