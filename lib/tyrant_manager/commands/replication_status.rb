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
        manager.each_instance( options['instances'] ) do |instance|
          if instance.running? and instance.is_slave? then
            s_stat = instance.stat
            logger.info "#{instance.name} is replicating from #{s_stat['mhost']}:#{s_stat['mport']}"
              if m_conn = validate_master_connection( instance ) then
                if validate_master_master( instance.connection, m_conn ) then
                  m_stat = m_conn.stat
                  m_name = "#{s_stat['mhost']}:#{s_stat['mport']}"

                  primary, failover = instance.connection, m_conn

                  if m_stat['delay'] > s_stat['delay'] then
                    primary, failover = m_conn, instance.connection
                  end

                  p_stat = primary.stat
                  p_name = "#{manager.ip_of( primary.host )}:#{primary.port}"

                  f_stat = failover.stat
                  f_name = "#{manager.ip_of( failover.host )}:#{failover.port}"

                  n_width = [ p_name.length, f_name.length ].max

                  logger.info "  Primary master  : #{p_name} -> #{p_stat['rnum']} records, primary since #{(Time.now - ( Float(primary.stat['delay']))).strftime("%Y-%m-%d %H:%M:%S")}"
                  logger.info "  Failover master : #{f_name} -> #{f_stat['rnum']} records, last replicated #{failover.stat['delay']} seconds ago"
                end
              end
            logger.info ""
          end
        end
      end

      private

      def validate_master_master( slave, master )
        m_stat = master.stat
        s_stat = slave.stat

        if ( m_stat['mhost'] and m_stat['mport'] ) then
          logger.info "  #{s_stat['mhost']}:#{s_stat['mport']} is replicating from #{m_stat['mhost']}:#{m_stat['mport']}"
          mm_ip = manager.ip_of( m_stat['mhost'] )
          s_ip = manager.ip_of( slave.host )
          if ( s_ip == mm_ip ) and ( slave.port == m_stat['mport'].to_i ) then
            #logger.info "    - this is a good master-master relationship"
            return true 
          else
            logger.error "  Unsupported replication configuration!!!"
            logger.error "  (original hostnames) #{slave.host}:#{slave.port} -> #{(master.host)}:#{master.port} -> #{m_stat['mhost']}:#{m_stat['mport']}"
            logger.error "  (hostnames resolved) #{s_ip}:#{slave.port} -> #{manager.ip_of(master.host)}:#{master.port} -> #{manager.ip_of(m_stat['mhost'])}:#{m_stat['mport']}"
            return false
          end
        end
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
