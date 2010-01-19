require 'tyrant_manager/command'
class TyrantManager
  module Commands
    #
    # Stop one or more tyrant instances
    #
    class Stop < Command
      def run
        manager.each_instance( options['instances'] ) do |instance|
          if File.exist?( instance.pid_file ) then
            logger.info "Stopping #{instance.name} : pid #{instance.pid}"
            instance.stop
          else
            logger.info "Stopping #{instance.name} : no pid file, nothing to do"
          end
        end
      end
    end
  end
end
