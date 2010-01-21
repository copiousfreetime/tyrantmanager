require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

require 'tyrant_manager'
require 'tyrant_manager/tyrant_instance'

describe TyrantManager::TyrantInstance  do
  before( :each ) do
    @tyrant_manager_dir = File.join( temp_dir, 'tyrant' )

    @instances = {
        'standalone'       => nil,
        'slave_1'          => nil,
        'master_master_1'  => nil,
        'master_master_2'  => nil 
      }
 
    TyrantManager::Log.silent {

      @mgr = TyrantManager.setup( @tyrant_manager_dir)

     @instances.keys.each do |name|
        idir = @mgr.instances_path( name )
        tyrant = TyrantManager::TyrantInstance.setup( idir )
        tyrant.manager = @mgr
        @instances[name] = tyrant
      end
    }
  end

  after( :each ) do
    FileUtils.rm_rf @tyrant_manager_dir
  end

  it "raises an exception if given an invalid directory on initialization" do
    lambda { TyrantManager::TyrantInstance.new( "/tmp" ) }.should raise_error( TyrantManager::Error, /tmp is not a valid archive/ )
  end

  it "#config_file" do
    @instances['standalone'].config_file.should == File.join( @tyrant_manager_dir, "instances", "standalone", "config.rb" )
    File.exist?( @instances['standalone'].config_file ).should == true
  end

  it "#configuration" do
    @instances['standalone'].configuration.should_not == nil
  end

  it "#pid_file" do
    @instances['standalone'].pid_file.should == File.join( @tyrant_manager_dir, "instances", "standalone", "standalone.pid" )
  end

  it "#log_file" do
    @instances['standalone'].log_file.should == File.join( @tyrant_manager_dir, "instances", "standalone", "log", "standalone.log" )
  end

  it "#replication_timestamp_file" do
    @instances['standalone'].replication_timestamp_file.should == File.join( @tyrant_manager_dir, "instances", "standalone", "standalone.rts" )
  end

  it "#lua_extension_file" do
    @instances['standalone'].lua_extension_file.should == File.join( @tyrant_manager_dir, "instances", "standalone", "lua", "standalone.lua" )
  end

  it "#data_dir" do
    @instances['standalone'].data_dir.should == File.join( @tyrant_manager_dir, "instances", "standalone", "data" )
  end

  describe "against running instances" do
    before( :each ) do
      @instances['standalone'].start
      start = Time.now
      loop do
        break if @instances['standalone'].running?
        sleep 0.1
        break if (Time.now - start) > 2
      end
    end

    after( :each ) do
      @instances['standalone'].stop
    end

    it "#is_slave? when it is not a slave" do
      @instances['standalone'].running?.should == true
      @instances['standalone'].should_not be_is_slave
      @instances['standalone'].stop
    end

    it "#is_slave? when it IS a slave" do
      @instances['standalone'].running?.should == true
      @instances['standalone'].should be_is_slave
      @instances['standalone'].stop
    end

  end


  describe "database types" do
    { 'memory-hash' => "*",
      'memory-tree' => "+",
      'hash'        => "tch",
      'tree'        => "tcb",
      'fixed'       => "tcf",
      'table'       => "tct"
    }.each_pair do |db_type, db_ext|
      it "db_type of #{db_type} is db file with ext #{db_ext}" do
        f = @instances['standalone'].db_file( db_type )
        if f.size == 1 then
          f.should == db_ext
        else
          f.should == File.join( @tyrant_manager_dir, "instances", "standalone", "data", "standalone.#{db_ext}" )
        end
      end
    end
  end

  it "#ulog_dir" do
    @instances['standalone'].ulog_dir.should == File.join( @tyrant_manager_dir, "instances", "standalone", "ulog" )
  end


  it "#start_command" do
    @instances['standalone'].start_command.should =~ /^ttserver/
  end

end
