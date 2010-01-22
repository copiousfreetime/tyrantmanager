require 'tyrant_manager/command'
require 'socket'

class TyrantManager
  module Commands
    #
    # Archive ulog files that are no longer used for replication.
    #
    # You must give the list of slave connection strings on the commandline, or 
    # if the server is in a single master-master relationship, then you can
    # allow tyrantmanager to figure that out and do the right thing.
    # 
    # Give the slaves of a particular master
    #
    #   tyrantmanager archive-ulogs master1 --slaves slave1:11011,slave2:11012,slave3:11013 
    #
    # Or if there is a master-master relationship tyrant manager can figure it
    # out.
    #
    #   tyrantmanager archive-ulogs master1
    #
    #
    class ArchiveUlogs < Command
      def self.command_name
        'archive-ulogs'
      end

      def run
        instance_slaves = determine_master_slave_mappings( options['slaves'] )

        manager.each_instance( options['instances'] ) do |instance|
          if instance.is_master_master? then
            manager.logger.debug "#{instance.name} is master_master"
            instance_slaves[instance.connection_string] << instance.master_connection
          end
          slave_connections = instance_slaves[instance.connection_string]

          potential_removals = potential_ulog_archive_files( instance )
          manager.logger.info "Checking #{slave_connections.size} slaves of #{instance.name}"

          slave_connections.each do |conn|
            potential_removals = trim_potential_removals( instance, potential_removals, conn )
          end

          archive_files_with_method( potential_removals.keys.sort, options['archive-method'] )

        end
      end

      #
      # Archive each of the files in the list with the given method
      #
      def archive_files_with_method( list, method )
        list.each do |fname|
          leader = (options['dry-run']) ? "(dry-run)" : ""
          if "delete" == method then
            File.unlink( fname ) unless options['dry-run']
            manager.logger.info "deleted #{leader} #{fname}"
          else
            if File.extname( fname ) == ".ulog" then
              %x[ gzip #{fname} ] unless options['dry-run']
              manager.logger.info "#{leader} compressed #{fname}"
            else
              manager.logger.info "#{leader} already compressed #{fname}"
            end
          end
        end
      end

      #
      # Remove all items from the potential removals list that have a timestamp
      # that is newer than the last replication timestamp of the tyrant
      # connection
      #
      def trim_potential_removals( master_instance, potential, slave_conn )
        slave_stat = slave_conn.stat
        milliseconds = Float( slave_stat['rts'] )
        last_replication_at = Time.at( milliseconds  / 1_000_000 )

        manager.logger.debug "Slave #{slave_conn.host}:#{slave_conn.port} last replicated at #{last_replication_at.strftime("%Y-%m-%d %H:%M:%S")} from #{master_instance.connection_string}"

        if milliseconds.to_i == 0 then
          manager.logger.warn "It appears that the slave at #{slave_conn.host}:#{slave_conn.port} has never replicated"
          manager.logger.warn "This means that no ulogs on the master will be removed, since there is no evidence of replication."
          manager.logger.warn "It may be necessary to force a replication by inserting a record into the master:"
          manager.logger.warn ""
          manager.logger.warn "    tcrmgr put -port #{master_instance.configuration.port} #{master_instance.configuration.host} __tyrant_manager.force_replication_at #{Time.now.utc.to_i}"
          manager.logger.warn ""
          manager.logger.warn "And then removing that record if you so choose:"
          manager.logger.warn ""
          manager.logger.warn "    tcrmgr out -port #{master_instance.configuration.port} #{master_instance.configuration.host} __tyrant_manager.force_replication_at"
          manager.logger.warn ""
        end

        manager.logger.debug "Trimming ulog files that are newer than #{last_replication_at.strftime("%Y-%m-%d %H:%M:%S")}"

        trimmed_potential = remove_newer_than( potential, last_replication_at )
      end

      #
      # Filter all the ulogs from the list whose value is greater than the input
      # time.
      #
      def remove_newer_than( potential, whence )
        potential.keys.sort.each do |fname|
          if potential[fname] > whence then
            potential.delete( fname )
          end
        end
        return potential
      end

      #
      # The list of potential files to remove from the ulog directory.  This is
      # all the files in the ulog directory, minus the last one lexically.
      #
      # A hash of filename => File.mtime values is returned
      #
      def potential_ulog_archive_files( instance )
        names = instance.ulog_files[0..-2]
        names += Dir.glob( "#{instance.ulog_dir}/*.ulog.gz" )
        potential = {}
        names.each do |name|
          potential[name] = File.mtime( name )
        end
        return potential
      end

      # Given a list of slaves, create a hash that has as the key, the instance
      # connection string of a master, as as the value, an array of
      # Rufus::Tokyo::Tyrant connections.
      #
      def determine_master_slave_mappings( list_of_slaves ) 
        master_to_slaves = Hash.new{ |h,k| h[k] = [] }

        list_of_slaves ||= []
        list_of_slaves.each do |connection_string|
          host, port = connection_string.split(":")
          conn = Rufus::Tokyo::Tyrant.new( host, port.to_i )
          stat = conn.stat
          master_host = stat['mhost']
          master_port = stat['mport']
          if master_host and master_port then
            master_to_slaves["#{master_host}:#{master_port}"] << conn
          else
            manager.logger.warn "Slave #{connection_string} does not have a master server configured, skipping using it as a slave"
          end
        end

        return master_to_slaves
      end
    end
  end
end
 
 
