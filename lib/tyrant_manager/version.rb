#--
# Copyright (c) 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details
#++

class TyrantManager
  module Version
    MAJOR   = 1
    MINOR   = 0
    BUILD   = 6

    def to_a 
      [MAJOR, MINOR, BUILD]
    end

    def to_s
      to_a.join(".")
    end

    def to_hash
      { :major => MAJOR, :minor => MINOR, :build => BUILD }
    end

    extend self
  end
  VERSION = Version.to_s
end
