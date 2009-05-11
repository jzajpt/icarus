# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{icarus}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ji\305\231\303\255 Zajpt"]
  s.date = %q{2009-05-11}
  s.description = %q{TODO}
  s.email = %q{jzajpt@blueberryapps.com}
  s.executables = ["icarus", "verify_icarus"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "Manifest.txt",
     "README.txt",
     "Rakefile",
     "VERSION",
     "bin/icarus",
     "bin/verify_icarus",
     "config/config.yml",
     "config/private.key",
     "config/server.crt",
     "lib/adapters/mysql_adapter.rb",
     "lib/backends/base.rb",
     "lib/backends/mysql.rb",
     "lib/backends/postfix.rb",
     "lib/backends/powerdns.rb",
     "lib/backends/proftpd.rb",
     "lib/backends/system.rb",
     "lib/ext/hash.rb",
     "lib/ext/icarus_servlet.rb",
     "lib/icarus.rb",
     "lib/icarus_config.rb",
     "lib/models/mysql/database.rb",
     "lib/models/mysql/user.rb",
     "lib/models/postfix/alias.rb",
     "lib/models/postfix/domain.rb",
     "lib/models/postfix/mailbox.rb",
     "lib/models/powerdns/domain.rb",
     "lib/models/powerdns/record.rb",
     "lib/models/proftpd/ftp_account.rb",
     "lib/stupid_record/attributes.rb",
     "lib/stupid_record/record.rb",
     "lib/verify_icarus.rb",
     "spec/adapters/mysql_adapter_spec.rb",
     "spec/backends/mysql_spec.rb",
     "spec/backends/postfix_spec.rb",
     "spec/backends/powerdns_spec.rb",
     "spec/backends/proftpd_spec.rb",
     "spec/backends/system_spec.rb",
     "spec/ext/hash_spec.rb",
     "spec/helpers/mysql_helper.rb",
     "spec/helpers/sql_helper.rb",
     "spec/models/mysql/database_spec.rb",
     "spec/models/mysql/user_spec.rb",
     "spec/models/postfix/alias_spec.rb",
     "spec/models/postfix/domain_spec.rb",
     "spec/models/postfix/mailbox_spec.rb",
     "spec/models/powerdns/domain_spec.rb",
     "spec/models/powerdns/record_spec.rb",
     "spec/models/proftpd/ftp_account_spec.rb",
     "spec/spec_helper.rb",
     "spec/stupid_record/record_spec.rb",
     "sql/postfix.sql",
     "sql/postfix_test_data.sql",
     "sql/powerdns.sql",
     "sql/powerdns_test_data.sql",
     "sql/proftpd.sql",
     "sql/proftpd_test_data.sql",
     "test/config.yml.erb",
     "test/test_icarus.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jzajpt/icarus}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Icarus is backend software for Daedalus.}
  s.test_files = [
    "spec/adapters/mysql_adapter_spec.rb",
     "spec/backends/mysql_spec.rb",
     "spec/backends/postfix_spec.rb",
     "spec/backends/powerdns_spec.rb",
     "spec/backends/proftpd_spec.rb",
     "spec/backends/system_spec.rb",
     "spec/ext/hash_spec.rb",
     "spec/helpers/mysql_helper.rb",
     "spec/helpers/sql_helper.rb",
     "spec/models/mysql/database_spec.rb",
     "spec/models/mysql/user_spec.rb",
     "spec/models/postfix/alias_spec.rb",
     "spec/models/postfix/domain_spec.rb",
     "spec/models/postfix/mailbox_spec.rb",
     "spec/models/powerdns/domain_spec.rb",
     "spec/models/powerdns/record_spec.rb",
     "spec/models/proftpd/ftp_account_spec.rb",
     "spec/spec_helper.rb",
     "spec/stupid_record/record_spec.rb",
     "test/test_icarus.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
