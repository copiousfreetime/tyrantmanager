require 'tyrant_manager/command'
class TyrantManager
  module Commands
    #
    # Report the status of one ore more tyrant intances
    #
    class ProcessStatus < Command
      def self.command_name
        'process-status'
      end

      def run
        manager.each_instance( options['instances'] ) do |instance|
          if instance.running? then
            logger.info "#{instance.name} is running as pid #{instance.pid}"
          else
            logger.info "#{instance.name} is not running, or its pid file is gone"
          end
        end
      end
    end
  end
end
