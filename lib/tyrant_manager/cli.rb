#gem 'fattr', '~> 1.1.0'
#gem 'main', "~> 2.9.3"
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
      description "Setup an tyrant manager location"
      argument( :home ) {
        description "The home directory of the tyrant manager"
        required
        default ::TyrantManager.default_or_home_directory
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

      run { ::TyrantManager::Cli.run_command_with_params( "create-instance", params ) }
    }

    mode( 'start' ) {
      description "Start all the tyrants listed"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances
      option( 'dry-run' ) {
        description "Do not start, just show the commands"
        default false
      }

      run { ::TyrantManager::Cli.run_command_with_params( 'start', params ) }
    }


    mode( 'stop' ) {
      description "Stop all the tyrants listed"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances

      run { ::TyrantManager::Cli.run_command_with_params( 'stop', params ) }
    }

    mode('replication-status') {
      description "Describe the replication status of those servers using replication"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances
      run { ::TyrantManager::Cli.run_command_with_params( 'replication-status', params ) }
    }

    mode('process-status') {
      description "Check the running status of all the tyrants listed"
      mixin :option_home
      mixin :option_log_level

      mixin :argument_instances

      run { ::TyrantManager::Cli.run_command_with_params( 'process-status', params ) }
    }

    mode( 'stats' ) {
      description "Dump the database statistics of each of the tyrants listed"
      mixin :option_home
      mixin :option_log_level

      mixin :argument_instances

      run { ::TyrantManager::Cli.run_command_with_params( 'stats', params ) }
    }


    mode('list') {
      description "list the instances and their home directories"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances
      run { ::TyrantManager::Cli.run_command_with_params( 'list', params ) }
    }

    mode( 'archive-ulogs' ) {
      description "Archive the ulog files that are no longer necessary for replication"
      mixin :option_home
      mixin :option_log_level
      mixin :argument_instances

      option( 'archive-method' ) {
        description "The method of archiving, compress, or delete.  Choosing 'delete' will also delete previously 'compressed' ulog files."
        argument :required
        validate { |m| %w[ compress delete ].include?( m.downcase ) }
        default "compress"
      }

      option( 'dry-run' ) {
        description "Do not archive, just show the commands"
        default false
      }

      option( 'force' ) {
        description "Force a record through the master to the slave so the replication timestamps are updated."
        default false
        cast :boolean
      }

      option('force-key') {
        description "When used with --force, this is the key that is forced from the master to the slaves.
        The value iinserted at the key is the current timestamp in the form 
        #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        argument :required
        default "__tyrant_manager.force_replication_at"
        cast :string
      }


      option( 'slaves' ) {
        description "Comma separated list of slave instances connection strings host:port,host:port,..."
        argument :required
        cast :list_of_string
      }

      run { ::TyrantManager::Cli.run_command_with_params( 'archive-ulogs', params ) }

    }


    #--- Mixins ---
    mixin :option_home do
      option( :home ) do
        description "The home directory of the tyrant manager"
        argument :required
        validate { |v| ::File.directory?( v ) }
        default ::TyrantManager.default_or_home_directory
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
