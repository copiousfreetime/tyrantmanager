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

      @instances.keys.each_with_index do |name, idx|
         idir = @mgr.instances_path( name )
         tyrant = TyrantManager::TyrantInstance.setup( idir )
         tyrant.manager = @mgr
         tyrant.configuration.port += idx
         tyrant.configuration.server_id = tyrant.configuration.port
         @instances[name] = tyrant
       end
    }

    # set the slave_1 to be a slave of the standalone
    @instances['slave_1'].configuration.master_server = "localhost"
    @instances['slave_1'].configuration.master_port   = @instances['standalone'].configuration.port

    # set the master_master pairs into a master_master relationship
    @instances['master_master_1'].configuration.master_server = "localhost"
    @instances['master_master_1'].configuration.master_port   = @instances['master_master_2'].configuration.port

    @instances['master_master_2'].configuration.master_server = "localhost"
    @instances['master_master_2'].configuration.master_port   = @instances['master_master_1'].configuration.port

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
    @instances['standalone'].configuration.nil?.should == false
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
      @instances.each_pair do |name, instance|
        instance.start
        start = Time.now
        #print "#{name} : starting ->"
        loop do
          break if instance.running?
          #print "+"
          $stdout.flush
          sleep 0.1
          break if (Time.now - start) > 3
        end
        #puts
      end
    end

    after( :each ) do
      @instances.each_pair do |name, instance|
        instance.stop
        start = Time.now
        #print "#{name} : stopping ->"
        loop do
          break unless instance.running?
          #print  "-"
          $stdout.flush
          sleep 0.1
          break if (Time.now - start) > 3
        end
        #puts
      end
    end

    it "#is_running?" do
      @instances.each_pair do |name, instance|
        [ name, instance.running? ].should == [ name, true ]
      end
    end

    it "#is_slave? when it is NOT a slave" do
      @instances['standalone'].running?.should == true
      @instances['standalone'].is_slave?.should == false
    end

    it "#is_slave? when it IS a slave" do
      @instances['slave_1'].running?.should == true
      @instances['slave_1'].is_slave?.should == true
    end

    it "#is_master_master? when it is NOT in a master_master relationship" do
      @instances['slave_1'].running?.should == true
      @instances['slave_1'].is_master_master?.should == false
    end

    it "#is_master_master? when it IS in a master_master relationship" do
      @instances['master_master_1'].running?.should == true
      @instances['master_master_1'].is_master_master?.should == true

      @instances['master_master_2'].running?.should == true
      @instances['master_master_2'].is_master_master?.should == true
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
