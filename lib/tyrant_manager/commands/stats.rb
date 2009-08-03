require 'tyrant_manager/command'
class TyrantManager
  module Commands
    #
    # List the stats about one or more instances
    #
    class Stats < Command
      def run
        manager.each_instance do |instance|
          ilist = options['instances']
          if ilist  == %w[ all ] or ilist.include?( instance.name ) then
            puts "Instance #{instance.name} at #{instance.home_dir}"
            stats = instance.stat
            stats.keys.sort.each do |k|
              lhs = k.ljust(10, ".")
              puts "    #{lhs} #{stats[k]}"
            end
            puts
          end
        end
      end
    end
  end
end
