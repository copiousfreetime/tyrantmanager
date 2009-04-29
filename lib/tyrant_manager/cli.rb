require 'main'
require 'tyrant_manager/runner'

module TyrantManager
  Cli = Main.create {
   author "Copyright 2009 (c) Jeremy Hinegardner"
   version ::TyrantManager::VERSION

   description <<-txt
   The command line tool for managing tyrant instances.

   Run 'tyrantmanager help modename' for more information
   txt

   run { help! }

   mode( :setup ) {
     option( :home ) do
       description "The home directory of the tyrant manager"
       argument :required
       default TyrantManager.home_dir
     end

     run { Cli.run_command_with_params( 'setup', params ) }
   }


   #--- Mixins ---
   mixin :option_home do
     option( :home ) do
       description "The home directory of the tyrant manager"
       argument :required
       validate { |v| ::File.directory?( v ) }
       default TyrantManager.home_dir
     end
   end

   mixin :option_log_level do
     option('log-level' ) do
       description "The verbosity of logging, one of [ #{::Logging::LNAMES.man {|l| l.downcase}.join(", ")} ]"
       argument :required
       validate { |l| %w[ debug info warn error fatal off ].include?( l.downcase ) }
     end
   end
end
