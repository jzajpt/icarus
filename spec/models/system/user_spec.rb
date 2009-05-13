require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe System::User do
  before(:all) do
    System::User.passwd = File.expand_path(File.dirname(__FILE__) + '/../../helpers/passwd_file')
    @mock_script = prepare_mock_script
  end

  it "should read attributes from passwd file" do
    # line in passwd 'jzajpt:x:5001:5001:Jiri Zajpt:/home/jzajpt:/bin/bash'
    user = System::User.find_by_name 'jzajpt'
    user.username.should    == 'jzajpt'
    user.uid.should         == 5001
    user.gid.should         == 5001
    user.home.should        == '/home/jzajpt'
    user.shell.should       == '/bin/bash'
    user.description.should == 'Jiri Zajpt'

    # line in passwd 'george::::::'
    user = System::User.find_by_name 'george'
    user.username.should    == 'george'
    user.uid.should         == 0
    user.gid.should         == 0
    user.home.should        be_nil
    user.shell.should       be_nil
    user.description.should be_nil
  end
  
  it "should return nil when no user was found" do
    user = System::User.find_by_name 'non-existent'
    user.should be_nil
  end
  
  it "should raise error when passwd file doesn't exist" do
    System::User.passwd = File.join(File.dirname(__FILE__), 'nonexistent-passwd')
    
    lambda { System::User.find_by_name 'hello' }.should raise_error
  end
  
  it "should normalize username" do
    System::User.useradd = @mock_script

    pairs = [
      %w(George george),
      %w(GEORGE george),
      %w(george.z george_z)
    ]
    
    pairs.each do |pair|
      System::User.normalize_username(pair[0]).should == pair[1]

      System::User.create(pair[0], :normalize_username => true).should == true
    end
  end

  describe "create action" do
    it "should raise when useradd binary doesn't exist" do
      System::User.useradd = File.join(File.dirname(__FILE__), 'non-existent-useradd')

      lambda { user = System::User.create('chorche') }.should raise_error
    end
    
    it "should return true when right username is specified" do
      System::User.useradd = @mock_script
    
      %w(george george-z george_z george012 george0- george0_ george_ george- _george _0george).each do |username|
        System::User.create(username, :create_home => true).should == true
      end
    end
    
    it "should return false when wrong username is specified" do
      System::User.useradd = @mock_script
      
      %w(0george -george george.z George gEORGE GEORGE).each do |username|
        System::User.create(username).should == false
      end
    end
    
    it "shouldn't create username with more than 32 chars" do
      System::User.useradd = @mock_script
      username = ""
      33.times { username << 'a' } 
      System::User.create(username).should == false
      
      username = ""
      32.times { username << 'a' }
      System::User.create(username).should == true  
    end
  end
  
  
  describe "delete action" do
    it "should raise when userdel binary doesn't exist" do
      System::User.userdel = File.join(File.dirname(__FILE__), 'non-existent-userdel')
    
      lambda { user = System::User.delete('chorche') }.should raise_error
    end
    
    it "should return true when deleted ok" do
      System::User.userdel = @mock_script
        
      System::User.delete('george').should == true
    end
  end  
  
  def prepare_mock_script
    path = "/tmp/mock#{rand(1000)}"
    File.open(path, "w") do |file|
      file.write <<-EOT
#!/bin/sh
exit 0
      EOT
    end
    File.chmod(0744, path)
    path
  end
end