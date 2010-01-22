require 'tyrant_manager/command'
class TyrantManager
  module Commands
    #
    # List the stats about one or more instances
    #
    class Stats < Command
      def run
        manager.each_instance( options['instances'] ) do |instance|
          puts "Instance #{instance.name} at #{instance.home_dir}"
          stats = instance.stat
          max_width = stats.keys.collect { |k| k.length }.sort.last + 2
          stats.keys.sort.each do |k|
            lhs = k.ljust(max_width, ".")
            puts "    #{lhs} #{stats[k]}"
          end
          puts
        end
      end
    end
  end
end
