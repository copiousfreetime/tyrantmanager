require 'tyrant_manager/command'
class TyrantManager
  class Start < Command
    def run
      manager.each_instance do |instance|
        ilist = options['instances']
        if ilist  == %w[ all ] or ilist.include?( instance.name ) then
          if not instance.running? then
            logger.info "Starting #{instance.name} : #{instance.start_command}"
            instance.start
          else
            logger.info "Instance #{instance.name} already running"
          end
        end
      end
    end
  end
end
