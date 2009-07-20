require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

require 'tyrant_manager'
require 'tyrant_manager/tyrant_instance'

describe TyrantManager::TyrantInstance  do
  before( :each ) do
    @tdir = File.join( temp_dir, 'tyrant' )
    TyrantManager::Log.silent {
      @mgr = TyrantManager.setup( @tdir )
      @idir   = @mgr.instances_path( "test" )
      @tyrant = TyrantManager::TyrantInstance.setup( @idir )
      @tyrant.manager = @mgr
    }
  end

  after( :each ) do
    FileUtils.rm_rf @tdir
  end

  it "#config_file" do
    @tyrant.config_file.should == File.join( @tdir, "instances", "test", "config.rb" )
    File.exist?( @tyrant.config_file ).should == true
  end

  it "#configuration" do
    @tyrant.configuration.should_not == nil
  end

  it "#pid_file" do
    @tyrant.pid_file.should == File.join( @tdir, "instances", "test", "test.pid" )
  end

  it "#log_file" do
    @tyrant.log_file.should == File.join( @tdir, "instances", "test", "log", "test.log" )
  end

  it "#replication_timestamp_file" do
    @tyrant.replication_timestamp_file.should == File.join( @tdir, "instances", "test", "test.rts" )
  end

  it "#lua_extension_file" do
    @tyrant.lua_extension_file.should == File.join( @tdir, "instances", "test", "lua", "test.lua" )
  end

  it "#data_dir" do
    @tyrant.data_dir.should == File.join( @tdir, "instances", "test", "data" )
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
        f = @tyrant.db_file( db_type )
        if f.size == 1 then
          f.should == db_ext
        else
          f.should == File.join( @tdir, "instances", "test", "data", "test.#{db_ext}" )
        end
      end
    end
  end

  it "#ulog_dir" do
    @tyrant.ulog_dir.should == File.join( @tdir, "instances", "test", "ulog" )
  end


  it "#start_command" do
    @tyrant.start_command.should == "foo"
  end

end
