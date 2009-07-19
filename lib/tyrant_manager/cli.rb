require 'main'
#require 'tyrant_manager/runner'

class TyrantManager
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

      run { 
        TyrantManager::Log.init 
        TyrantManager.setup( params['home'].value ) 
      }
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
  }

  #
  # Convert the Parameters::List that exists as the parameters from Main
  #
  def Cli.params_to_hash( params )
    (hash = params.to_hash ).keys.each { |key| hash[key] = hash[key].value }
    return hash
  end

  def Cli.run_command_with_params( command, params )
    phash = Cli.params_to_hash( params )
    TyrantManager::Log.init( phash )
    tm = TyrantManager.new( phash.delete('home') )
    tm.runner_for( phash ).run( command )
  end 
end
