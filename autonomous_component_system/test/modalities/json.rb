module Skylab::Autonomous_Component_System::TestSupport

  module Modalities::JSON

    def self.[] tcc
      tcc.include self
    end

    def unmarshal_from_JSON acs, cust=nil, io

      block_given? and raise ::ArgumentError

      _oes_p = event_log.handle_event_selectively
      _pp = -> _ do
        _oes_p
      end

      _x = Home_.unmarshal_from_JSON acs, cust, io, & _pp

      _x
    end

    def marshal_JSON_into io, * x_a, acs

      block_given? and raise ::ArgumentError

      _oes_p = event_log.handle_event_selectively
      _pp = -> _ do
        _oes_p
      end

      Home_.marshal_to_JSON io, * x_a, acs, & _pp
    end
  end
end
