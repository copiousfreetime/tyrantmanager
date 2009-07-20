require 'pathname'
require 'tyrant_manager/command'
class TyrantManager
  class List < Command
    def run
      manager.each_instance do |instance|
        ilist = options['instances']
        if ilist  == %w[ all ] or ilist.include?( instance.name ) then
          puts "#{"%20s" % instance.name} : #{instance.home_dir}"
        end
      end
    end
  end
end
