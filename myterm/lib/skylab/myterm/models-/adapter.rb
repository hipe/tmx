module Skylab::MyTerm

  module Models_::Adapter

    class << self

      def interpret_component st, cust, & pp

        Adapter_via_Argument_Stream___[ st, cust.kernel_, & pp ]
      end
    end  # >>

    class Adapter_via_Argument_Stream___ < Callback_::Actor::Dyadic

      def initialize st, k, & pp
        @_arg_st = st
        @kernel_ = k
        @_pp = pp
      end

      def execute

        _ok = __resolve_load_ticket_via_argument_stream
        _ok &&= __resolve_adapter_via_load_ticket
      end

      def __resolve_adapter_via_load_ticket

        lt = remove_instance_variable :@_load_ticket

        _mod = lt.module

        _o = _mod.interpret_compound_component(
          IDENTITY_, lt.adapter_name, @kernel_, & @_pp )

        _o
      end

      def __resolve_load_ticket_via_argument_stream

        _adapters_silo = @kernel_.silo :Adapters
        _stream_method = _adapters_silo.method :to_load_ticket_stream

        _x = @_arg_st.current_token

        @_oes_p = @_pp[ nil ]

        o = Home_.lib_.brazen::Collection::Common_fuzzy_retrieve.new( & @_oes_p )

        o.name_map = -> lt do
          lt.stem
        end

        o.stream_builder = -> do
          _adapters_silo.to_load_ticket_stream
        end

        o.set_qualified_knownness_value_and_symbol _x, :adapter_name

        lt = o.execute
        if lt
          remove_instance_variable( :@_arg_st ).advance_one
          @_load_ticket = lt
          ACHIEVED_
        else
          lt
        end
      end
    end

    IDENTITY_ = -> x { x }
  end
end
# #pending-rename: b.d
