delete from domains;
alter table domains auto_increment = 1;
delete from records;
alter table records auto_increment = 1;

INSERT INTO domains (id, name, type) values (1, 'blueberry.cz', 'NATIVE');
INSERT INTO domains (id, name, type) values (2, 'jzajpt.cz', 'NATIVE');

INSERT INTO records (domain_id, name, content, type, ttl, prio) VALUES
  (1, 'blueberry.cz', 'localhost root@blueberry.cz', 'SOA', 600, NULL),
  (1, 'blueberry.cz', 'ns1.28labs.com', 'NS', 600, NULL),
  (1, 'blueberry.cz', 'ns2.28labs.com', 'NS', 600, NULL),
  (1, 'blueberry.cz', 'mx.28labs.com', 'MX', 600, 10),
  (1, 'ns1.blueberry.cz', '81.0.213.225', 'A', 120, NULL),
  (1, 'ns2.blueberry.cz', '81.0.213.225', 'A', 120, NULL),
  (1, 'mx.blueberry.cz', '81.0.213.225', 'A', 120, 10),
  (1, 'bender.blueberry.cz', '81.0.213.225', 'A', 120, NULL),
  (1, 'shorty.blueberry.cz', '81.0.239.25', 'A', 120, NULL),
  (1, 'padme.blueberry.cz', '81.0.223.76', 'A', 120, NULL),
  (1, 'www.blueberry.cz', '81.0.213.225', 'A', 120, NULL),
  (1, 'blueberry.cz', '81.0.213.225', 'A', 120, NULL),
  (2, 'jzajpt.cz', 'localhost root@blueberry.cz', 'SOA', 600, NULL),
  (2, 'jzajpt.cz', 'ns1.28labs.com', 'NS', 600, NULL),
  (2, 'jzajpt.cz', 'ns2.28labs.com', 'NS', 600, NULL),
  (2, 'jzajpt.cz', 'mx.28labs.com', 'MX', 600, 10),
  (2, 'www.jzajpt.cz', '81.0.213.225', 'A', 120, NULL);

