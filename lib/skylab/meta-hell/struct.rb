module Skylab::MetaHell
  module Struct # just a namespace !
    def self.[] h # just a pretty opacity
      MetaHell::FUN.hash2struct[ h ]
    end
  end
end
