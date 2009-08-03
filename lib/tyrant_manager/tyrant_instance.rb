require 'tyrant_manager'
require 'rufus/tokyo/tyrant'
require 'erb'

class TyrantManager
  class TyrantInstance
    class << TyrantInstance
      def logger
        Logging::Logger[self]
      end
      #
      # Create all the directories needed for a tyrant
      #
      def setup( dir )
        unless File.directory?( dir )
          logger.info "Creating directory #{dir}"
          FileUtils.mkdir_p( dir )
        end

        cfg = File.join( dir, TyrantManager.config_file_basename )
        instance_name = File.basename( dir )

        unless File.exist?( cfg )
          template = TyrantManager::Paths.data_path( "default_instance_config.rb" )
          logger.info "Creating default config file #{cfg}"
          File.open( cfg, "w+" ) do |f|
            f.write ERB.new( IO.read( template ) ).result( binding )
          end
        end

        %w[ ulog data lua log ].each do |subdir|
          subdir = File.join( dir, subdir )
          unless File.directory?( subdir ) then
            logger.info "Creating directory #{subdir}"
            FileUtils.mkdir subdir 
          end
        end

        return TyrantInstance.new( dir )
      end
    end

    # the full path to the instance home directory
    attr_reader :home_dir

    # the name of this instance
    attr_reader :name 

    # the manager that is associated with this instance
    attr_accessor :manager

    #
    # Create an instance connected to the tyrant located in the given directory
    #
    def initialize( dir )
      @home_dir = File.expand_path( dir )
      @name     = File.basename( @home_dir )
      if File.exist?( self.config_file ) then
        configuration # force a load
      else
        raise Error, "#{home_dir} is not a valid archive. #{self.config_file} does not exist"
      end
    end

    def logger
      Logging::Logger[self]
    end

    #
    # The configuration file for the instance
    #
    def config_file
      @config_file ||= File.join( home_dir, TyrantManager.config_file_basename ) 
    end

    #
    # load the configuration
    #
    def configuration
      unless @configuration then
        eval(  IO.read( self.config_file ) )
        @configuration = Loquacious::Configuration.for( name )
      end
      return @configuration
    end

    #
    # The pid file
    #
    def pid_file
      @pid_file ||= append_to_home_if_not_absolute( configuration.pid_file )
    end

    #
    # The pid of the service
    #
    def pid
      Float( IO.read( pid_file ).strip ).to_i
    end

    #
    # The log file
    #
    def log_file
      @log_file ||= append_to_home_if_not_absolute( configuration.log_file )
    end

    #
    # The lua extension file to load on start
    #
    def lua_extension_file
      @lua_extension_file ||= append_to_home_if_not_absolute( configuration.lua_extension_file )
    end

    #
    # The lua extension file to load on start
    #
    def replication_timestamp_file
      @replication_timestamp_file ||= append_to_home_if_not_absolute( configuration.replication_timestamp_file )
    end

    #
    # The directory housing the database file
    #
    def data_dir
      @data_dir ||= append_to_home_if_not_absolute( configuration.data_dir )
    end

    #
    # The full path to the database file.
    #
    def db_file( type = configuration.type )
      unless @db_file then
        @db_file = case type
                   when "memory-hash" then "*"
                   when "memory-tree" then "+"
                   when "hash"        then File.join( data_dir, "#{name}.tch" )
                   when "tree"        then File.join( data_dir, "#{name}.tcb" )
                   when "fixed"       then File.join( data_dir, "#{name}.tcf" )
                   when "table"       then File.join( data_dir, "#{name}.tct" )
                   else
                     raise Error, "Unknown configuration type [#{configuration.type}]"
                   end
      end
      return @db_file
    end

    #
    # The directory housing the database file
    #
    def ulog_dir
      @ulog_dir ||= append_to_home_if_not_absolute( configuration.ulog_dir )
    end

    #
    # The lua extension file
    #
    def lua_extension_file
      @lua_extension_file ||= append_to_home_if_not_absolute( configuration.lua_extension_file )
    end

    #
    # The replication timestamp file
    #
    def replication_timestamp_file
      @replication_timestamp_file ||= append_to_home_if_not_absolute( configuration.replication_timestamp_file )
    end


    #
    # Start command.
    #
    # This is a bit convoluted to bring together all the options and put them
    # into one big commandline item.  
    #
    def start_command

      ##-- ttserver executable
      parts = [ manager.configuration.ttserver ]

      ##-- host and port
      parts << "-host #{configuration.host}" if configuration.host
      parts << "-port #{configuration.port}" if configuration.port

      ##-- thread options
      if thnum = cascading_config( 'thread_count' ) then
        parts << "-thnum #{thnum}"
      end
      if tout = cascading_config( 'session_timeout' ) then
        parts << "-tout #{tout}"
      end

      ##-- daemoization and pid
      parts << "-dmn" if cascading_config( 'daemonize' )
      parts << "-pid #{pid_file}"


      ##-- logging
      parts << "-log #{log_file}"
      if log_level = cascading_config( 'log_level' ) then
        if log_level == "error" then
          parts << "-le"
        elsif log_level == "debug" then
          parts << "-ld" 
        elsif log_level == "info" then
          # leave it at info
        else
          raise Error, "Invalid log level setting [#{log_level}]"
        end
      end

      ##-- update logs
      parts << "-ulog #{ulog_dir}"
      if ulim = cascading_config( 'update_log_size' )then
        parts << "-ulim #{ulim}"
      end
      parts << "-uas" if cascading_config( 'update_log_async' )

      ##-- replication items, server id, master, replication timestamp file
      parts << "-sid #{configuration.server_id}"       if configuration.server_id
      parts << "-mhost #{configuration.master_server}" if configuration.master_server
      parts << "-mport #{configuration.master_port}"   if configuration.master_port
      parts << "-rts #{replication_timestamp_file}" if configuration.replication_timestamp_file

      ##-- lua extension
      if configuration.lua_extension_file then
        if File.exist?( lua_extension_file ) then
          parts << "-ext #{lua_extension_file}" 
          if pc = configuration.periodic_command then
            if pc.name and pc.period then
              parts << "-extpc #{pc.name} #{pc.period}"
            end
          end
        end
      end

      ##-- command permissiosn
      if deny = cascading_config( "deny_commands" ) then
        parts << "-mask #{deny.join(",")}"
      end

      if allow = cascading_config( "allow_commands" ) then
        parts << "-unmask #{allow.join(",")}"
      end

      ##-- now for the filename.  The format is
      #  filename.ext#opts=ld#mode=wc#tuning_param=value#tuning_param=value...
      #
      file_pairs = []
      file_pairs << "opts=#{configuration.opts}"
      file_pairs << "mode=#{configuration.mode}"
      Loquacious::Configuration::Iterator.new( configuration.tuning_params ).each do |node|
        file_pairs << "#{node.name}=#{node.obj}" if node.obj
      end

      file_name_and_params = "#{db_file}##{file_pairs.join("#")}"

      parts << file_name_and_params

      return parts.join( " " )  
    end

    #
    # Start the tyrant
    #
    def start
      o = %x[ #{start_command} ]
      logger.info o
    end

    # 
    # kill the proc
    #
    def stop
      begin
        _pid = self.pid
        Process.kill( "TERM" , _pid )
        logger.info "Sent signal TERM to #{_pid}"
      rescue Errno::EPERM
        logger.info "Process #{_pid} is beyond my control"
      rescue Errno::ESRCH
        logger.info "Process #{_pid} is dead"
      rescue => e
        logger.error "Problem sending kill(TERM, #{_pid}) : #{e}"
      end
    end


    #
    # check if process is alive
    #
    def running?
      begin
        if File.exist?( self.pid_file ) then
          _pid = self.pid
          Process.kill( 0, _pid )
          return true
        else
          return false
        end
      rescue Errno::EPERM
        logger.info "Process #{_pid} is beyond my control"
      rescue Errno::ESRCH
        logger.info "Process #{_pid} is dead"
        return false
      rescue => e
        logger.error "Problem sending kill(0, #{_pid}) : #{e}"
      end
    end

    #
    # return the stats for this instance
    #
    def stat
      connection.stat
    end

    #
    # return a network connection to this instance
    #
    def connection
      host = configuration.host

      # you cannot connect to 0.0.0.0
      if host == "0.0.0.0" then
        host = "localhost"
      end
      Rufus::Tokyo::Tyrant.new( configuration.host, configuration.port.to_i )
    end

    #
    # Is this instance a slave of another server?  This means it could be in a
    # master-slave or master-master relationship
    #
    def is_slave?
      s = connection.stat
      return (s['mhost'] and s['mport'])
    end

    #
    # return a network connection to the master server of this instance
    #
    def master_connection
      if is_slave? then
        s = self.stat
        return Rufus::Tokyo::Tyrant.new( s['mhost'], s['mport'].to_i )
      end
      return nil
    end

 
    private

    #
    # take the given path, and if it is not an absolute path append it 
    # to the home directory of the instance.
    def append_to_home_if_not_absolute( p )
      path = Pathname.new( p )
      unless path.absolute? then
        path = Pathname.new( home_dir ) + path
      end
      return path.to_s
    end

    #
    # retrieve the cascading option from our config or the managers config if we
    # don't have it.
    #
    def cascading_config( name )
      configuration[name] || manager.configuration.instance_defaults[name]
    end
  end
end
