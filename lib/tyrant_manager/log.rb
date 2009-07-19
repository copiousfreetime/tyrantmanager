require 'logging'
require 'tyrant_manager'

class TyrantManager
  ::Logging::Logger[self].level = :info

  def self.logger
    ::Logging::Logger[self]
  end

  module Log
    def self.init( options = {} )
      appender = Logging.appenders.stderr 
      appender.layout = self.console_layout
      if options['log-file'] then
        appender = ::Logging::Appenders::File.new(
          'tyrant_manager',
          :filename => options['log-file'],
          :layout   => self.layout
        )
      end

      TyrantManager.logger.add_appenders( appender )
      self.level = options['log-level'] || :info
    end

    def self.logger
      TyrantManager.logger
    end

    def self.default_level
      :info
    end

    def self.console
      Logging.appenders.stderr.level
    end

    def self.console=( level )
      Logging.appenders.stderr.level = level
    end

    def self.level
      ::Logging::Logger[TyrantManager].level
    end

    def self.level=( l )
      ::Logging::Logger[TyrantManager].level = l
    end

    def self.layout
      @layout ||= Logging::Layouts::Pattern.new(
        :pattern      => "[%d] %5l %6p %c : %m\n",
        :date_pattern => "%Y-%m-%d %H:%M:%S"
      )
    end

    def self.console_layout
      @layout ||= Logging::Layouts::Pattern.new(
        :pattern      => "%d %5l : %m\n",
        :date_pattern => "%H:%M:%S"
      )
    end

    #   
    # Turn off the console logging
    #   
    def self.silent!
      logger.level = :off
    end 

    #   
    # Resume logging
    #   
    def self.resume
      logger.level = self.default_level
    end 

    #   
    # Turn off logging for the execution of a block
    #   
    def self.silent( &block )
      begin
        silent!
        block.call
      ensure
        resume
      end
    end
  end
end
