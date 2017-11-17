module Skylab::Arc::TestSupport

  module JSON_Magnetics

    Lite = -> tcc do
      tcc.send :define_method, :subject_magnetics_module_ do
        Home_::JSON_Magnetics
      end
    end

    def self.[] tcc
      tcc.include self
      Lite[ tcc ]
    end

    def unmarshal_from_JSON acs, cust=nil, io

      block_given? and raise ::ArgumentError

      _p = event_log.handle_event_selectively
      _pp = -> _ do
        _p
      end

      _x = Home_.unmarshal_from_JSON acs, cust, io, & _pp

      _x
    end

    def marshal_JSON_into io, * x_a, acs

      block_given? and raise ::ArgumentError

      _p = event_log.handle_event_selectively
      _pp = -> _ do
        _p
      end

      Home_.marshal_to_JSON io, * x_a, acs, & _pp
    end
  end
end
