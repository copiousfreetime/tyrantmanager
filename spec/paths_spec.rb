require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe TyrantManager::Paths do
  before(:each) do
    @root_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    @root_dir += "/"
  end

  it "root dir should be correct" do
    TyrantManager::Paths.root_dir.should == @root_dir
  end

  it "home dir should be correct" do
    TyrantManager::Paths.home_dir.should == @root_dir
  end

  %w[ bin lib spec config log tmp ].each do |d|
    it "#{d} path should be correct" do
      TyrantManager::Paths.send( "#{d}_path" ).should == File.join(@root_dir, "#{d}/" )
    end
  end

  describe "setting home_dir" do
    before( :each ) do
      @tmp_dir = "/some/location/#{Process.pid}"
      TyrantManager::Paths.home_dir = @tmp_dir
    end

    %w[ config log tmp instances ].each do |d|
      check_path = "#{d}_path"
      it "affects the location of #{check_path}" do
        p = TyrantManager::Paths.send( check_path )
        p.should == ( File.join( @tmp_dir, d ) + File::SEPARATOR )
      end
    end

    %w[ bin lib spec ].each do |d|
      check_path = "#{d}_path"
      it "does not affect the location of #{check_path}" do
        p = TyrantManager::Paths.send( check_path )
        p.should == ( File.join( @root_dir, d ) + File::SEPARATOR )
      end
    end
  end

  describe "Default TyrantManager home_dir" do
    it 'has a different default home_dir for the top level TyrantManager' do
      TyrantManager.home_dir.should == File.join( Config::CONFIG['localstatedir'], 'lib', 'tyrant' )
    end
    
    it "has an instances dir" do
      TyrantManager.default_instances_dir.should == File.join( Config::CONFIG['localstatedir'], 'lib', 'tyrant', 'instances' ) + "/"
    end
  end
end
