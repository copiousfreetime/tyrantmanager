require 'rubygems'
require 'spec'

$:.unshift File.expand_path( File.join( File.dirname( __FILE__ ),"..","lib"))

module TempDirHelper
  require 'tmpdir'
  def temp_dir( unique_id = $$ )
    dirname = File.join( Dir.tmpdir, "tyrant-spec-#{unique_id}" )
    FileUtils.mkdir_p( dirname ) unless File.directory?( dirname )
    # for osx
    dirname = Dir.chdir( dirname ) { Dir.pwd }
  end
end

