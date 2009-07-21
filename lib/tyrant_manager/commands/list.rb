require 'pathname'
require 'tyrant_manager/command'
class TyrantManager
  class List < Command
    def run
      manager.each_instance do |instance|
        ilist = options['instances']
        if ilist  == %w[ all ] or ilist.include?( instance.name ) then
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
