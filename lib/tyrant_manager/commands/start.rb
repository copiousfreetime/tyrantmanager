require 'tyrant_manager/command'
class TyrantManager
  class Start < Command
    def run
      manager.each_instance do |instance|
        ilist = options['instances']
        if ilist  == %w[ all ] or ilist.include?( instance.name ) then
          parts = [ "Starting #{instance.name}" ]
          parts << instance.start_command

          if options['dry-run'] then
            parts << "(dry-run)"
            logger.info parts.join(" : ")

          elsif not instance.running? then
            logger.info parts.join(" : ")
            Dir.chdir( instance.home_dir ) do
              instance.start 
            end
          else
            logger.info "Instance #{instance.name} already running"
          end
        end
      end
    end
  end
end
