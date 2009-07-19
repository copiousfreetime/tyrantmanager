#--
# Copyright (c) 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'tyrant_manager/version'
require 'tyrant_manager/paths'
require 'tyrant_manager/log'

class TyrantManager
  include TyrantManager::Paths

  class Error < StandardError; end

  class << TyrantManager
    #
    # The basename of the default config file
    #
    def config_file_basename
      "config.rb"
    end

    #
    # The basename of the directory that holds the tyrant manager system
    #
    def basedir
      "tyrant"
    end

    #
    # is the given directory a tyrant root directory.  A tyrant root has a
    # +config_file_basename+ file in the top level
    #
    def is_tyrant_root?( dir )
      cfg = File.join( dir, config_file_basename )
      return true if File.directory?( dir ) and File.exist?( cfg )
      return false
    end

    #
    # Return the path of the tyrant dir if there is one relative to the current
    # working directory.  This means that there is a +config_file_basename+ in
    # the current working directory.
    #
    # returns Dir.pwd if this is the case, nil otherwise
    #
    def cwd_default_directory
      default_dir = Dir.pwd
      return default_dir if is_tyrant_root?( default_dir )
      return nil
    end

    # 
    # Return the path of the tyrant dir as it pertains to the
    # TYRANT_MANAGER_HOME environment variable.  If the directory is 
    # a tyrant root, then return that directory, otherwise return nil
    #
    def env_default_directory
      default_dir = ENV['TYRANT_MANAGER_HOME']
      return default_dir if default_dir and is_tyrant_root?( default_dir )
      return nil
    end

    #
    # Return the path of the tyrant dir as it pertains to the default global
    # setting of 'lcoalstatedir' which is /opt/local/var, /var, or similar
    #
    def localstate_default_directory
      default_dir = File.join( Config::CONFIG['localstatedir'], basedir )
      return default_dir if is_tyrant_root?( default_dir )
      return nil
    end

    #
    # The default tyrant directory.  It is the first of these that matches:
    #
    # * current directory if there is a +config_file_basename+ file in the
    #   current dirctory
    # * the value of the TYRANT_MANAGER_HOME environment variable
    # * File.join( Config::CONFIG['localstatedir'], basedir )
    #
    def default_directory
      defaults = [ self.cwd_default_directory,
                   self.env_default_directory,
                   self.localstate_default_directory ]
      dd = nil
      loop do
        dd = defaults.shift
        break if dd or defaults.empty?
      end
      raise Error, "No default_directory found" unless dd
      return dd
    end


    #
    # Setup the tyrant manager in the given directory.  This means creating it
    # if it does not exist.
    #
    def setup( dir = default_directory )
      unless File.directory?( dir )
        logger.info "Creating directory #{dir}"
        FileUtils.mkdir_p( dir )
      end

      cfg = File.join( dir, config_file_basename )

      unless File.exist?( cfg )
        template = TyrantManager::Paths.data_path( config_file_basename )
        logger.info "Creating default config file #{cfg}"
        FileUtils.cp( template, dir )
      end

      %w[ instances log tmp ].each do |subdir|
        subdir = File.join( dir, subdir )
        logger.info "Creating dirctory #{subdir}"
        FileUtils.mkdir subdir
      end
    end
  end

  #
  # Initialize the manager, which is nothing more than creating the instance and
  # setting the home directory.
  #
  def initialize( directory = TyrantManager.default_directory )
    self.home_dir = File.expand_path( directory ) 
    if File.exist?( self.config_file ) then
      configuration # force a load
    else
      raise Error, "#{home_dir} is not a valid archive. #{self.config_file} does not exist"
    end
  end

  #
  # The configuration file for the manager
  #
  def config_file
    @config_file ||= File.join( home_dir, TyrantManager.config_file_basename ) 
  end

  #
  # load the configuration
  #
  def configuration
    @configuration ||= eval( IO.read( config_file ) )
  end

  #
  # Create a runner instance with the given options
  #
  def runner_for( options )
    Runner.new( self, options )
  end
end

require 'tyrant_manager/cli'
#require 'tyrant_manager/tyrant_instance'
