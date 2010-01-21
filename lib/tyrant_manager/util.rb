class TyrantManager
  module Util
    def ip_of( hostname )
      hostname = Socket.gethostname if %w[ localhost 0.0.0.0 ].include?( hostname )
      addr_info = Socket.getaddrinfo( hostname, 1978, "AF_INET" )
      return addr_info.first[3]
    end
  end
end
