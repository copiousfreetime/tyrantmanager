require 'main'
require 'tyrant_manager'

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
      argument( :home ) {
        description "The home directory of the tyrant manager"
        required
        default TyrantManager.home_dir
      }

      run { 
        TyrantManager::Log.init 
        TyrantManager.setup( params['home'].value ) 
      }
    }

    mode( 'create-instance' ) {
      description <<-txt
      Create a new tyrant instance in the specified directory
      txt

      argument( 'instance-home' ) do
        description <<-txt
        The home directory of the tyrant instance.  If this is a full path it 
        will be used.  If it is a relative path, it will be relative to the 
        manager's 'instances' configuration parameter
        txt
      end

      mixin :option_home
      mixin :option_log_level

      run { Cli.run_command_with_params( "create-instance", params ) }
    }

    mode( 'start' ) {
      description "Start all the tyrants listed"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances

      run { Cli.run_command_with_params( 'start', params ) }
    }


    mode( 'stop' ) {
      description "Stop all the tyrants listed"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances

      run { Cli.run_command_with_params( 'stop', params ) }
    }


    mode('status') {
      description "Check the running status of all the tyrants listed"
      mixin :option_home
      mixin :option_log_level

      mixin :argument_instances

      run { Cli.run_command_with_params( 'status', params ) }
    }

    mode( 'stats' ) {
      description "Dump the database statistics of each of the tyrants listed"
      mixin :option_home
      mixin :option_log_level

      mixin :argument_instances

      run { Cli.run_command_with_params( 'stats', params ) }
    }


    mode('list') {
      description "list the instances and their home directories"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances
      run { Cli.run_command_with_params( 'list', params ) }
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
      option('log-level') do
        description "The verbosity of logging, one of [ #{::Logging::LNAMES.map {|l| l.downcase}.join(", ")} ]"
        argument :required
        validate { |l| %w[ debug info warn error fatal off ].include?( l.downcase ) }
      end
    end

    mixin :argument_instances do
      argument('instances') do
        description "A comman separated list of instance names the tyrant manager  knows about"
        argument :required
        cast :list
        default 'all'
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
