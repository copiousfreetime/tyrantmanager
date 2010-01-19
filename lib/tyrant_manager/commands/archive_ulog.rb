require 'tyrant_manager/command'
require 'socket'

class TyrantManager
  module Commands
    #
    # Archive ulog files that are no longer used for replication
    #
    class ArchiveUlogs < Command
      def self.command_name
        'archive-ulogs'
      end

      def run
        
      end
    end
  end
end
 
 
