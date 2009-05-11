require 'xmlrpc/server'
require 'webrick'

class IcarusServlet < XMLRPC::WEBrickServlet
  attr_accessor :username
  attr_accessor :password

  def service(request, response)
    WEBrick::HTTPAuth.basic_auth(request, response, '') do |auth_user, auth_pass|
      auth_user == @username && auth_pass == @password
    end
    super
  end
end