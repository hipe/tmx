module Skylab::Fields::TestSupport

  module Event::Failure_Graph_Expression

    def self.[] tcc
      tcc.include self
    end

    # -- setup

    def name_ sym
      Common_::Name.via_variegated_symbol sym
    end

    def begin_stub_ sym
      Branch_Stub.new sym
    end

    def new_with_reasons_ * a
      new_with_reasons_array_ a
    end

    def new_with_reasons_array_ a
      __new_with(
        :reasons, a
      )
    end

    def __new_with * x_a
      Home_::Events::Missing.construct do  # #[#ca-012]#A you wish it was one method
        process_iambic_fully x_a
        freeze
      end
    end

    # -- assertion

    def event_message_as_string_
      _event_message_into_buffer ""
    end

    def event_message_as_line_array_
      _event_message_into_buffer []
    end

    def _event_message_into_buffer buffer

      _y = ::Enumerator::Yielder.new do |line|
        if do_debug
          io = debug_IO
          io.write line
        end
        buffer << line
      end

      _expag = my_all_purpose_expression_agent_
      _ev = self.event_
      _ev.express_into_under _y, _expag
      buffer
    end

    class Branch_Stub

      def initialize sym
        @_nf = Common_::Name.via_variegated_symbol( sym )
        @_reasons = nil
      end

      def _add_reason x
        ( @_reasons ||= [] ).push x ; nil
      end

      def emissions

        _a = remove_instance_variable :@_reasons
        [ Emission_for_Missing___.new( _a, @_nf ) ]
      end

      def compound_formal_attribute
        @_nf
      end

      self
    end

    class Emission_for_Missing___

      def initialize a, nf

        @mixed_event_proc = -> do
          _ = Home_::Events::Missing.new_with(
            :selection_stack, [ nil, nf ],
            :reasons, a,
          )
          _
        end
      end

      attr_reader(
        :mixed_event_proc,
      )

      def channel
        SAME___
      end

      SAME___ = [ :_hact_, :_anything_but_emission_ ]

      nil
    end
  end
end
