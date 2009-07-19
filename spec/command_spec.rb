require File.expand_path( File.join( File.dirname( __FILE__ ),"spec_helper.rb"))

require 'tyrant_manager/command'

class Junk < TyrantManager::Command; end

describe TyrantManager::Command do
  before( :each ) do
    @cmd = TyrantManager::Command.new
  end

  it "has a command name" do
    @cmd.command_name.should == "command"
  end

  it "can log" do
    @cmd.logger.info "this is a log statement"
    spec_log.should =~ /this is a log statement/
  end

  it "raises an error if it cannot find the class required" do
    lambda { TyrantManager::Command.find( "foo" ) }.should raise_error( TyrantManager::Command::CommandNotFoundError, 
                                                                       /No command for 'foo' was found./ )
  end

  it "registers inherited classes" do
    TyrantManager::Command.list.should be_include( Junk )
    TyrantManager::Command.list.delete( Junk )
    TyrantManager::Command.list.should_not be_include(Junk)
  end

  it "classes cannot be run without implementing 'run'" do
    j = Junk.new
    j.respond_to?(:run).should == true
    lambda { j.run }.should raise_error( NotImplementedError, /The #run method must be implemented/)
  end
end
