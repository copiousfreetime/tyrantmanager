require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

require 'tyrant_manager'

describe TyrantManager do
  before( :each ) do
    @tdir = File.join( temp_dir, 'tyrant' )
    TyrantManager::Log.silent {
      @mgr  = TyrantManager.setup( @tdir )
    }
    #TyrantManager::Log.level = :debug
  end

  after( :each ) do
    #puts spec_log
    FileUtils.rm_rf @tdir
  end

  describe "#default_directory" do
    it "uses the current working directory" do
      Dir.chdir( @tdir ) do |d|
        TyrantManager.default_directory.should == d
      end
    end

    it "uses the TYRANT_MANAGER_HOME environment variable" do
      ENV['TYRANT_MANAGER_HOME'] = @tdir
      TyrantManager.default_directory.should == @tdir
    end
  end

  it "initializes with an existing directory" do
    t = TyrantManager.new( @tdir )
    t.config_file.should == File.join( @tdir, "config.rb" )
  end

  it "raises an error if attempting to initialize from a non-existent tyrnat home" do
    lambda { TyrantManager.new( "/tmp" ) }.should raise_error( TyrantManager::Error, /\/tmp is not a valid archive/ )
  end

  it "#config_file" do
    @mgr.config_file.should == File.join( @tdir, "config.rb" )
    File.exist?( @mgr.config_file ).should == true
  end

  it "#configuration" do
    @mgr.configuration.nil?.should == false
  end

  it "has the location of the ttserver command" do
    @mgr.configuration.ttserver.should == "ttserver"
  end

  it "iterates over all its instances" do
    3.times do |x|
      idir   = @mgr.instances_path( "test#{x}" )
      TyrantManager::TyrantInstance.setup( idir )
    end

    @mgr.instances.size.should == 3
    names = []
    @mgr.each_instance do |i|
      i.name.should =~ /test\d/
      names << i.name
    end

    names.sort.should == %w[ test0 test1 test2 ]
  end

  it "iterates over a subset of instances" do
    3.times do |x|
      idir   = @mgr.instances_path( "test#{x}" )
      TyrantManager::TyrantInstance.setup( idir )
    end

    @mgr.instances.size.should == 3
    names = []
    @mgr.each_instance( %w[ test0 test2] ) do |i|
      i.name.should =~ /test\d/
      names << i.name
    end

    names.sort.should == %w[ test0 test2 ]
  end

end
