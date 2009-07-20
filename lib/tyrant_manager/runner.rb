require 'tyrant_manager/command'

class TyrantManager
  class Runner

    attr_reader :options
    attr_reader :manager

    def initialize( manager, opts = {} )
      @manager = manager
      @options = opts
    end

    def logger
      ::Logging::Logger[self]
    end

    def run( command_name )
      cmd = Command.find( command_name ).new( self.manager, self.options )
      begin
        cmd.before
        cmd.run
      rescue => e
        logger.error "while running #{command_name} : #{e.message}"
        e.backtrace.each do |l|
          logger.warn l.strip
        end
      ensure
        cmd.after
      end
    end
  end
end
