require 'tyrant_manager/command'
class TyrantManager
  class Stop < Command
    def run
      manager.each_instance do |instance|
        ilist = options['instances']
        if ilist  == %w[ all ] or ilist.include?( instance.name ) then
          logger.info "Stopping #{instance.name} : pid #{instance.pid}"
          instance.stop
        end
      end
    end
  end
end
