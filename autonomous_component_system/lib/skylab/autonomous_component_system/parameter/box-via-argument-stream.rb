module Skylab::Autonomous_Component_System

  class Parameter

    class Box_via_Argument_Stream < Callback_::Actor::Dyadic  # 1x

      # currently result in array of values in formal order or raise.

      Require_field_library_[]

      class << self
        public :new
      end  # >>

      def initialize arg_st, sel_stack, foz

        @argument_stream = arg_st
        @_current_formal = nil
        @_formal_box = foz.box
        @formals = foz
        @selection_stack = sel_stack
      end

      def current_symbol= sym
        @_current_formal = @_formal_box.fetch sym
        sym
      end

      def execute

        ___init_empty_output_box_in_formal_order
        __parse
        __finish
      end

      def ___init_empty_output_box_in_formal_order

        h = {}
        @_formal_box.a_.each do |k|
          h[ k ] = nil
        end
        @_out_box = Callback_::Box.via_integral_parts @_formal_box.a_.dup, h
        NIL_
      end

      def __parse

        st = @argument_stream

        if @_current_formal

          if st.no_unparsed_exists
            self._DO_ME_probably_finish
          else
            _assume_and_accept_value
          end
        else
          h = @_formal_box.h_
          begin
            if st.no_unparsed_exists
              break
            end
            @_current_formal = h[ st.current_token ]
            if @_current_formal
              st.advance_one
              _assume_and_accept_value
              redo
            end
            break
          end while nil
        end
        NIL_
      end

      def _assume_and_accept_value

        _x = @argument_stream.gets_one
        @_out_box.replace @_current_formal.name_symbol, _x
        NIL_
      end

      def __finish  # #[#117]

        miss_a = nil

        act_h = @_out_box.h_
        st = @_formal_box.to_value_stream

        begin
          par = st.gets
          par or break
          k = par.name_symbol

          # Field_::Takes_many_arguments[ par ]  not our concern for now..

          x = act_h.fetch k
          if x.nil? && Field_::Has_default[ par ]
            x = par.default_proc.call
            act_h[ k ] = x
          end

          if Field_::Is_required[ par ] && x.nil?
            ( miss_a ||= [] ).push par
          end

          redo
        end while nil

        if miss_a
          raise ::ArgumentError, ___say_missing( miss_a )
            # [#004]#exe explains why we raise here
        else
          _ = @_out_box.enum_for( :each_value ).to_a
          _
        end
      end

      def ___say_missing par_a

        _s_a = @selection_stack[ 1 .. -1 ].map do |qk|
          "`#{ qk.name.as_variegated_symbol }`"
        end

        _for = " for #{ _s_a * SPACE_ }"

        _s_a = par_a.map do |par|
          "`#{ par.name_symbol }`"
        end

        "missing required argument(s) (#{ _s_a * ', '})#{ _for }"
      end
    end
  end
end
