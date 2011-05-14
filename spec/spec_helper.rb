require 'rspec'
require 'logging'

$:.unshift File.expand_path( File.join( File.dirname( __FILE__ ),"..","lib"))


Logging::Logger['TyrantManager'].level = :all

module RSpec
  module Log
    def self.io
      @io ||= StringIO.new
    end
    def self.appender
      @appender ||= Logging::Appenders::IO.new( "speclog", io )
    end

    Logging::Logger['TyrantManager'].add_appenders( Log.appender )

    def self.layout
      @layout ||= Logging::Layouts::Pattern.new(
        :pattern      => "[%d] %5l %6p %c : %m\n",
        :date_pattern => "%Y-%m-%d %H:%M:%S"
      )
    end

    Log.appender.layout = layout
  end

  module Helpers
    require 'tmpdir'
    def temp_dir( unique_id = $$ )
      dirname = File.join( Dir.tmpdir, "tyrant-spec-#{unique_id}" )
      FileUtils.mkdir_p( dirname ) unless File.directory?( dirname )
      # for osx
      dirname = Dir.chdir( dirname ) { Dir.pwd }
    end

    def spec_log
      Log.io.string
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Helpers

  config.before do
    RSpec::Log.io.rewind
    RSpec::Log.io.truncate( 0 )
  end

  config.after do
    RSpec::Log.io.rewind
    RSpec::Log.io.truncate( 0 )
  end
end
