require 'tyrant_manager/command'
require 'socket'

class TyrantManager
  module Commands
    #
    # Report on the replication status of the server(s)
    #
    class ReplicationStatus< Command
      def self.command_name
        'replication-status'
      end

      def run
        manager.each_instance do |instance|
          ilist = options['instances']
          if ilist  == %w[ all ] or ilist.include?( instance.name ) then
            if instance.running? and instance.is_slave? then
              s_stat = instance.stat
              logger.info "#{instance.name} is replicating from master at #{s_stat['mhost']}:#{s_stat['mport']}"
              if m_conn = validate_master_connection( instance ) then
                if validate_master_master( instance.connection, m_conn ) then
                  m_stat = m_conn.stat
                  m_name = "master #{s_stat['mhost']}:#{s_stat['mport']}"
                  n_width = [ m_name.length, instance.name.length ].max

                  logger.info "  #{instance.name.rjust(n_width)} : records => #{s_stat['rnum']}, delay => #{s_stat['delay']} seconds"
                  logger.info "  #{m_name.rjust(n_width)} : records => #{m_stat['rnum']}, delay => #{m_stat['delay']} seconds"
                end
              end
            end
          end
        end
      end

      private

      def validate_master_master( slave, master )
        m_stat = master.stat
        s_stat = slave.stat

        if ( m_stat['mhost'] and m_stat['mport'] ) then
          logger.info "  master is replicating from #{m_stat['mhost']}:#{m_stat['mport']}"
          mm_ip = ip_of( m_stat['mhost'] )
          s_ip = ip_of( slave.host )
          if ( s_ip == mm_ip ) and ( slave.port == m_stat['mport'].to_i ) then
            logger.info "  This is a good master-master relationship"
          else
            logger.error "  Unsupported replication configuration!!!"
            logger.error "  (original hostnames) #{slave.host}:#{slave.port} -> #{(master.host)}:#{master.port} -> #{m_stat['mhost']}:#{m_stat['mport']}"
            logger.error "  (hostnames resolved) #{s_ip}:#{slave.port} -> #{ip_of(master.host)}:#{master.port} -> #{ip_of(m_stat['mhost'])}:#{m_stat['mport']}"
          end
        end
      end

      def ip_of( hostname )
        hostname = Socket.gethostname if %w[ localhost 0.0.0.0 ].include?( hostname )
        addr_info = Socket.getaddrinfo( hostname, 1978, "AF_INET" )
        return addr_info.first[3]
      end

      def validate_master_connection( slave ) 
        begin
          m_conn = slave.master_connection
          m_stat = m_conn.stat
          return m_conn
        rescue => e
          logger.error e
          s_stat = slave.stat
          logger.error "Master server #{s_stat["mhost"]}:#{s_stat['mport']} appears to be down."
        end
        return nil
      end
    end
  end
end
