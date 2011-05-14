#--
# Copyright (c) 2009-2011 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'pathname'
require 'tyrant_manager/command'
class TyrantManager
  module Commands
    #
    # Create a new Tyrant instance
    #
    class CreateInstance < Command
      def self.command_name
      'create-instance'
      end

      def run
        path = Pathname.new( options['instance-home'] )
        unless path.absolute? then
          path = Pathname.new( manager.instances_path ) + path
        end

        unless path.exist? then
          logger.info "Creating instance directory #{path}"
          TyrantManager::TyrantInstance.setup( path.to_s )
        end
        tt = TyrantManager::TyrantInstance.new( path.to_s )
      end
    end
  end
end
