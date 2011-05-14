#--
# Copyright (c) 2009-2011 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'pathname'
require 'tyrant_manager/command'
class TyrantManager
  module Commands
    #
    # List all known instances that the manager knows about
    #
    class List < Command
      def run
        manager.each_instance( options['instances'] ) do |instance|
          parts = []
          parts << ("%20s" % instance.name)
          parts << "port #{instance.configuration.port}"
          parts << instance.home_dir

          if instance.configuration.master_server then
            parts << "server id #{"%2d" % instance.configuration.server_id}"
            parts << "replicating from #{instance.configuration.master_server}:#{instance.configuration.master_port}"
          end
          puts parts.join(" : ")
        end
      end
    end
  end
end
