require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

describe TyrantManager::Paths do
  before(:each) do
    @root_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    @root_dir += "/"
  end

  it "root dir should be correct" do
    TyrantManager.root_dir.should == @root_dir
  end

  it "home dir should be correct" do
    TyrantManager.home_dir.should == @root_dir
  end

  %w[ bin lib spec config data log tmp ].each do |d|
    it "#{d} path should be correct" do
      TyrantManager.send( "#{d}_path" ).should == File.join(@root_dir, "#{d}/" )
    end
  end

  describe "setting home_dir" do
    before( :each ) do
      @tmp_dir = "/some/location/#{Process.pid}"
      TyrantManager.home_dir = @tmp_dir
    end

    %w[ config data log tmp ].each do |d|
      check_path = "#{d}_path"
      it "affects the location of #{check_path}" do
        p = TyrantManager.send( check_path )
        p.should == ( File.join( @tmp_dir, d ) + File::SEPARATOR )
      end
    end

    %w[ bin lib spec ].each do |d|
      check_path = "#{d}_path"
      it "does not affect the location of #{check_path}" do
        p = TyrantManager.send( check_path )
        p.should == ( File.join( @root_dir, d ) + File::SEPARATOR )
      end
    end
  end
end
