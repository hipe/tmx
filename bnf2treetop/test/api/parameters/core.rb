
module Skylab::BNF2Treetop::TestSupport

  module API::Parameters

    def self.[] tcc
      API[ tcc ]
      tcc.include self
    end

    def normal_of str
      s = str.gsub RX___, SPACE_
      s.strip!
      s
    end

    RX___ = %r([[:space:]]+)
  end
end
