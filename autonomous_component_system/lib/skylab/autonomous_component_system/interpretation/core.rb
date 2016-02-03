module Skylab::Autonomous_Component_System

  module Interpretation

    find_handler_method = nil
    Build_emission_handler_builder_ = -> asc, acs do  # 1x here

      # "component handler builder" (experimental): pass component listener
      # both the component value and association whenever it emits.
      # #open "go this away" this overcomplicated eventmodel that we don't use

      -> cmp do  # :[#006]:codepoint-1

        -> * i_a, & x_p do

          qkn = Callback_::Qualified_Knownness[ cmp, asc ]

          st = Callback_::Polymorphic_Stream.via_array i_a

          m = find_handler_method[ st, acs ]

          if m
            _maybe_none = st.flush_remaining_to_array

            acs.send m, qkn, * _maybe_none, & x_p
          else

            acs.receive_component_event qkn, i_a, & x_p
          end
        end
      end
    end

    find_handler_method = -> st, acs do

      # shift elements from the channel on to the method
      # name as long as there is a matching method

      base = :"receive_component__"
      begin

        try_m = :"#{ base }#{ st.current_token }__"

        if acs.respond_to? try_m
          m = try_m
          st.advance_one
          if st.unparsed_exists
            base = try_m
            redo
          end
        end
        break
      end while nil
      m
    end

    class Value_Popper  # 2x here Xx [ze] [#006]#VP

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize x
        @_done = false
        @_kn = Callback_::Known_Known[ x ]
      end

      def gets_one
        x = current_token
        advance_one
        x
      end

      def current_token
        @_kn.value_x
      end

      def advance_one
        remove_instance_variable :@_kn
        @_done = true ; nil
      end

      def unparsed_exists
        ! @_done
      end

      def no_unparsed_exists
        @_done
      end
    end

    IDENTITY_ = -> x { x }
  end
end
