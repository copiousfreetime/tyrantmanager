#--
# Copyright (c) 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'tyrant_manager/version'
require 'tyrant_manager/paths'

module TyrantManager
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
    # TYRANT_MANAGER_ROOT environment variable.  If the directory is 
    # a tyrant root, then return that directory, otherwise return nil
    #
    def env_default_directory
      default_dir = EVN['TYRANT_MANAGER_ROOT']
      return default_dir if default_dir and is_tyrant_root?( default_dir )
      return nil
    end

    #
    # Return the path of the tyrant dir as it pertains to the default global
    # setting of 'lcoalstatedir' which is /opt/local/var, /var, or similar
    #
    def localstate_default_directory
      default_dir = File.join( Config::CONFIG['localstatedir'], basedir )
      return default_dir if is_tyrant_root( default_dir )
      return nil
    end
  end
end

require 'tyrant_manager/cli'
require 'tyrant_manager/tyrant_instance'
