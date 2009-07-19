require File.expand_path(File.join(File.dirname(__FILE__),"spec_helper.rb"))

require 'tyrant_manager'

describe TyrantManager do
  include TempDirHelper
  before( :each ) do
    @tdir = File.join( temp_dir, 'tyrant' )
    TyrantManager::Console.silent {
      @tyrant  = TyrantManager.setup( @tdir )
    }
  end

  after( :each ) do
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
end