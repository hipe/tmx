module Skylab::Zerk

  class NonInteractiveCLI

    class Option_Parser_Controller___  # many code-notes in [#015]

      # see "our main argument is.."

      def initialize fo_frame, & pp
        @_fo_frame = fo_frame
        @_oes_pp = pp
        execute  # ..
      end

      def execute

        # work backwards from the topmost frame
        #
        #   • in case we do something clever with scope and "closeness"..
        #
        #   • so that the order of the options has the options more closely
        #     associated with the operation appearing higher on the screen

        @_op = Home_.lib_.stdlib_option_parser.new

        seen_h = ::Hash.new { |h,k| h[k] = true ; false }
        see = -> k do
          if seen_h[ k ]
            fail __say_seen k
          end
        end

        ss = @_fo_frame.formal_operation_.selection_stack
        d = ss.length - 2 ;  # not the formal operation frame, the one before

        begin
          _frame = ss.fetch d
          st = _frame.to_association_stream_for_option_parser___
          begin
            asc = st.gets
            asc or break
            see[ asc.name_symbol ]
            __express_atomesque_into_optionparser asc, d
            redo
          end while nil

          if d.zero?
            break
          end
          d -= 1
          redo
        end while nil

        @_ok = true
        @_selection_stack = ss

        NIL_
      end

      def ___say_seen k
        "cannot isomorph option parser - multiple associations named #{
          }'#{ k }' (but if support for this is desired, this is [#018])"
      end

      def __express_atomesque_into_optionparser asc, d

        # go thru normal validation when you accept values off the o.p
        # #open [#019] flags in o.p. #open [#020] argument monikers

        @_op.on "--#{ asc.name.as_slug } X" do |s|

          ___receive_unsanitized_value s, asc, @_selection_stack.fetch( d )
        end

        NIL_
      end

      # "thoughts on availability.."

      def ___receive_unsanitized_value s, asc, frame

        p = asc.unavailability_proc
        if p
          unava_p = p[ asc ]
        end
        if unava_p
          self._WAHOO_this_will_be_fun_for_open  # #open [#022]
        end

        _value_popper = Home_.lib_.fields::Argument_stream_via_value[ s ]

        _oes_pp = -> _ do
          # the model doesn't know the component's asssociation but we do:
          @_oes_pp[ asc ]
        end

        qk = ACS_::Interpretation::Build_value.call(
          _value_popper,
          asc,
          frame.ACS,
          & _oes_pp
        )

        if qk
          frame.reader_writer_.write_value qk
        else
          @_ok = qk  # because of the way o.p is, we can't elegantly stop it
        end
        NIL_
      end

      # --

      def option_parser___
        @_op
      end

      def ok__
        remove_instance_variable :@_ok
      end
    end
  end
end
