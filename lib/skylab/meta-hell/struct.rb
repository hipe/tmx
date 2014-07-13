module Skylab::MetaHell
  module Struct # just a namespace !
    def self.[] h # just a pretty opacity
      MetaHell_::FUN.hash2struct[ h ]
    end
  end
end
