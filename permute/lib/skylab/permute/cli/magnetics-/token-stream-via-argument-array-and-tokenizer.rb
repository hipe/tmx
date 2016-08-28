module Skylab::Permute

  class CLI

    class Sessions_::Custom_Parse_Session

      def initialize & oes_p

        @do_mutate_argument_array = true
        @_oes_p = oes_p  # on event selectively
      end

      attr_writer :argument_array,
        :do_mutate_argument_array,
        :long_help_switch,
        :short_help_switch

      def execute

        a = @argument_array
        if a.length.zero?
          @_oes_p.call :case, :no_arguments do end
        else
          __via_some_arguments
        end
      end

      def __via_some_arguments

        argv = @argument_array
        st = Common_::Polymorphic_Stream.via_array argv
        @_st = st

        is_help = [ @short_help_switch, @long_help_switch ].method :include?

        if st.unparsed_exists

          token = st.current_token

          is_help_ = is_help[ token ]
          if ! is_help_ && 1 < argv.length
            is_help_ = is_help[ argv.last ]
          end
        end

        user_x = if is_help_

          __send_help_directive
        else
          __result_via_state_machine
        end

        if @do_mutate_argument_array

          @argument_array[ 0, st.current_index ] = EMPTY_A_
        end

        user_x
      end

      def __send_help_directive

        @_oes_p.call :directive, :help do
          @_st
        end
      end

      def __result_via_state_machine

        _sm = Actors_::Build_state_machine[]

        _sm.against( @_st, & @_oes_p )
      end
    end
  end
end
