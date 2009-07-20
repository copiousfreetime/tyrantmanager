require 'tyrant_manager'
class TyrantManager
  #
  # The Command is the base class for any class to be used as a command
  #
  # All commands run within the context of an existing TyrantManager location.
  # Before the command starts the current working directory will be inside the
  # tyrant manager's home directory.
  #
  # A command has a lifecyle of:
  #
  # * instantiation with a TyrantManager instance and an options hash
  # * one call to before
  # * one call to run
  # * one call to after
  # 
  # In case of an exception raised during the lifecycle, the +error+ method will
  # be called.  The +after+ method is called no matter what at the end of the
  # lifecycle, even if an error has occurred.
  #
  class Command
    def self.command_name
      name.split("::").last.downcase
    end

    attr_reader :options
    attr_reader :manager

    # 
    # Instantiated and given the tyrant manager instance it is to operate
    # through and a hash of options
    #
    def initialize( manager, opts = {} )
      @manager = manager
      @options = opts
    end

    def command_name
      self.class.command_name
    end

    def logger
      Logging::Logger[self]
    end

    #------------------------------------------------------------------ 
    # lifecycle calls
    #------------------------------------------------------------------ 

    # 
    # call-seq:
    #   cmd.before
    #
    # called to allow the command to setup anything post initialization it
    # needs to be able to +run+.
    #
    def before() nil ; end

    #
    # call-seq:
    #   cmd.run
    #
    # Yeah, this is where the work should be done.
    #
    def run() 
      raise NotImplementedError, "The #run method must be implemented"
    end

    # 
    # call-seq:
    #   cmd.after
    #
    # called no matter what, after the execution of run() or error() if there was
    # an exception.  It is here to allow the cmd to do cleanup work.
    #
    def after()  nil ; end

    #
    # call-seq:
    #   cmd.error( exception )
    #
    # called if there is an exception during the before() or after() calls.  It
    # is passed in the exception that was raised.
    #
    def error(exception)  nil ; end

    #------------------------------------------------------------------ 
    # registration
    #------------------------------------------------------------------ 
    class CommandNotFoundError < ::TyrantManager::Error ; end
    class << Command
      def inherited( klass )
        return unless klass.instance_of? Class
        self.list << klass
      end

      def list
        unless defined? @list
          @list = Set.new
        end
        return @list
      end

      def find( command )
        klass = list.find { |klass| klass.command_name == command }
        return klass if klass
        names = list.collect { |c| c.command_name }
        raise CommandNotFoundError, "No command for '#{command}' was found.  Known commands : #{names.join(",")}"
      end
    end
  end
end
require 'tyrant_manager/commands/create_instance'
require 'tyrant_manager/commands/start'
require 'tyrant_manager/commands/stop'
require 'tyrant_manager/commands/status'
require 'tyrant_manager/commands/stats'
require 'tyrant_manager/commands/list'
