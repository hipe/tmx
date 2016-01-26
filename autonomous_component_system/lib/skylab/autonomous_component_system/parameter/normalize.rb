module Skylab::Autonomous_Component_System

  class Parameter

    class Normalize

      # if for flat platform parameters, produce an argument array.
      # otherwise (and for random access), do that.
      # for both, do defaults and check missing requireds.

      Require_field_library_[]

      def initialize arg_st, sel_stack, fo_bx

        @argument_stream = arg_st
        @_current_formal = nil
        @_formal_box = fo_bx
        @selection_stack = sel_stack
      end

      def current_symbol= sym
        @_current_formal = @_formal_box.fetch sym
        sym
      end

      def to_flat_platform_arguments

        bx = __build_box_for_flat_platform_arguments

        @_intake = -> x do
          bx.replace @_current_formal.name_symbol, x
          NIL_
        end
        _intake

        args = []
        @_accept = -> x, par do
          if Field_::Takes_many_arguments[ par ]
            if x
              args.concat x
            end
          else
            args.push x
          end
        end
        _normalize_against bx
        args
      end

      def write_into o

        bx = Callback_::Box.new

        @_intake = -> x do

          _k = @_current_formal.name_symbol
          bx.add _k, x
          NIL_
        end
        _intake

        @_accept = -> x, par do

          o.send :"#{ par.name_symbol }=", x
          NIL_
        end

        _normalize_against bx

        NIL_
      end

      def __build_box_for_flat_platform_arguments

        # must be a fully nil'd out box in formal order

        h = {}
        @_formal_box.a_.each do |k|
          h[ k ] = nil
        end
        Callback_::Box.via_integral_parts @_formal_box.a_.dup, h
      end

      def _intake

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
        @_intake[ _x ]
        NIL_
      end

      def _normalize_against out_bx  # #[#117]

        miss_a = nil

        act_h = out_bx.h_
        st = @_formal_box.to_value_stream

        begin
          par = st.gets
          par or break
          k = par.name_symbol

          had = true
          x = act_h.fetch k do
            had = false ; nil
          end

          did = false
          if x.nil? && Field_::Has_default[ par ]
            x = par.default_proc.call
            did = true
          end

          if Field_::Is_required[ par ] && x.nil?
            ( miss_a ||= [] ).push par
            redo
          end

          if had || did
            # (for random access, don't write nils if they were not passed)
            @_accept[ x, par ]
          end

          redo
        end while nil

        if miss_a
          raise ::ArgumentError, ___say_missing( miss_a )
            # [#004]#exe explains why we raise here
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
