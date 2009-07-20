require 'tyrant_manager/command'
class TyrantManager
  class Status < Command
    def run
      manager.each_instance do |instance|
        ilist = options['instances']
        if ilist  == %w[ all ] or ilist.include?( instance.name ) then
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
