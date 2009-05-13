require 'test/unit'
require 'xmlrpc/client'
require 'digest/sha2'
require 'yaml'
require 'rubygems'

$: << File.join(File.dirname(__FILE__), "/../lib") 
require 'icarus_config'
require 'icarus'

# Start Icarus server in separate thread
Thread.abort_on_exception = true
Thread.new do
  icarus = Icarus.new
  icarus.start
end
sleep(1) # Wait for server to get ready

# IcarusConfig should be loaded by Icarus

$server = XMLRPC::Client.new_from_uri(IcarusConfig.server_uri)
$server.user = IcarusConfig[:icarus][:username]
$server.password = IcarusConfig[:icarus][:password]
