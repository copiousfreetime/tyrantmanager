#--
# Copyright (c) 2009-2011 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'tyrant_manager/command'
class TyrantManager
  module Commands
    # 
    # Start one ore more instances
    #
    class Start < Command
      def run
        manager.each_instance( options['instances'] ) do |instance|
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
