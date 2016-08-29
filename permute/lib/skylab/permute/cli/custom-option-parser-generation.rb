module Skylab::Permute

  module CLI

    class CustomOptionParserGeneration

      # this is the main interesting thing about the implementation of [pe]
      # is that it's the frotier of #mode-tweaking by insisting on using
      # this custom option paser. any time structured data has to get across
      # the CLI-ACS boundary, some kind of cleverness needs to be employed
      # for the syntax. (think of the syntax for the `find` utility).

      # were it not this custom o.p, the lone parameter of our core operation
      # would be expressed as a required (positional) glob argument (because
      # the formal parameter has a nonzero parameter arity and a plural
      # argument arity (that is that is, it is required and it accepts one
      # or more values. see [#ze-015]. [#ac-026] is about plural-ness.)
      #
      # here we parse the entire ARGV with our custom parser and send the
      # 'value-name' pair list back to the ACS explicitly. we need to
      # remove explicitly the generated expression of the formal parameter
      # in the positional arguments, both so it does not appear in help
      # screens and so the arg parsing does not try to parse terms that
      # are not there.

      class << self

        alias_method :begin_for, :new
        undef_method :new
      end  # >>

      def initialize fr
        @stack_frame = fr
      end

      def finish
        # we are doing both expression and interpretation on our own:
        @stack_frame.remove_positional_argument :value_name_pair
        self
      end

      def summary_indent
        '  '
      end

      def summary_width
        2
      end

      def parse_in_order argv, setter, & nonopt

        # #hook-out expecting [#ze-015] #public-API:Point-1

        CaseWorker___.new( argv, @stack_frame, setter, nonopt ).execute
        NIL
      end

      def main_syntax_string_parts

        s_a = [ '--your-category YOUR-VALUE',
          '[ -y VALUE2 [ -y VAL3 [..]]]',
          '--other-cat VAL',
          '[ -o V2 [ -o V3 [..]]]' ]

        # (we used to expose mutation of the array here; see tombstone)
        s_a
      end

      # ~ begin mock another object with same class

      def top
        self
      end

      def list
        EMPTY_A_
      end

      # ~ end

      def summarize y
        y << "[ \"options\" are a wide-open namespace for your categories ]"
      end

      # ==

      class CaseWorker___

        # might rename to "parse". the subject responsibilities are:
        #
        #   1) call a chain of magnetics. this is boring and almost
        #      boilerplate glue, and although we could use [#ta-005] to
        #      automate it, for now we keep it intact so it is more opaque
        #      and simpler to debug.
        #
        #   2) all throughout the above pipeline, there are numerous possible
        #      error cases that have to be handled. (the CLI syntax for this
        #      is trickier than one might at first expect.) we have to be
        #      able to handle all of these and express them to the user in
        #      the expected ways.
        #
        #   3) the main challenge in doing the above is that we are behind
        #      a wall of acting like an option parser, so our normal event
        #      model is out the window. (in fact, reconciling that is our
        #      main challenge here.) that is, we don't have a handle on
        #      a selective event listener (proc); we have to communicate back
        #      to the client exacly as the platform o.p does, through the use
        #      of the `setter` proc being used to send simple structured
        #      messages.

        def initialize a, fr, p, p_
          @argv = a
          @nonopt = p_
          @setter = p
          @stack_frame = fr
        end

        def execute  # side-effects only

          @_lib = Zerk_lib_[]::NonInteractiveCLI::OptionParserController
          @_oes_p = method :___handle_anything

          ok = __resolve_token_stream_via_ARGV_and_tokenizer
          ok &&= __resolve_value_name_stream_via_token_stream
          ok && __send_value_name_stream
          NIL
        end

        def __send_value_name_stream

          # (this is kind of nasty because we're type-overloading a member
          # variable that is supposed to carry a string from the o.p back
          # to the model - but since the component model is written expecting
          # this structured data, it works out remarkably.)

          _vns = remove_instance_variable :@__value_name_stream
          _par = @stack_frame.formal_parameter :value_name_pairs
          _ast = @_lib::Assignment.new _vns, _par
          @setter[ NOTHING_, _ast ]
          NIL
        end

        def __resolve_value_name_stream_via_token_stream

          _ts = remove_instance_variable :@__token_stream
          _ = Here_::Magnetics_::ValueNameStream_via_TokenStream[ _ts, & @_oes_p ]
          _if _, :@__value_name_stream
        end

        def __resolve_token_stream_via_ARGV_and_tokenizer

          _argv = remove_instance_variable :@argv
          _ts = Here_::Magnetics_::TokenStream_via_ArgumentArray_and_Tokenizer[ _argv, & @_oes_p ]
          _if _ts, :@__token_stream
        end

        def ___handle_anything * i_a, & ev_p

          _m = i_a.reduce EEK___ do |h, sym|
            h.fetch sym
          end
          send _m, ev_p
          NIL
        end

        EEK___ = {
          error: {
            ambiguous_property: :__ambiguous_property,
            case: {
              no_available_state_transition: :__no_available_state_transition,
            },
            expression: {
              parse_error: :__parse_error_expression,
            },
            extra_properties: :__extra_properties,
          },
          extra_functional: {
            help: :__helporino,
          },
        }

        # (for every method body below that is identical to another, there is
        # of course the option of DRYing it up by having a single method that
        # we reference multiple times in the tree above. (neat, huh?) for now
        # we are leaving it unwound which e.g will could expose coverage so we
        # know when parts of our tree are not used.)

        def __parse_error_expression y_p
          _send y_p, :parse_error_expression
          NIL
        end

        def __extra_properties ev_p
          _send ev_p[], :parse_error_event
          NIL
        end

        def __no_available_state_transition ev_p
          _send ev_p[], :parse_error_event
          NIL
        end

        def __ambiguous_property ev_p
          _send ev_p[], :parse_error_event
          NIL
        end

        def __helporino xx
          _x = xx[]
          :_no_data_from_help_for_now_ == _x || self._SANITY  # #todo
          _send NOTHING_, :help  # no argument token
          NIL
        end

        def _send * a, m
          _si = @_lib::SpecialDirective.new( * a, m )
          @setter[ NOTHING_, _si ]
          NIL
        end

        def _if x, ivar
          if x
            instance_variable_set ivar, x ; ACHIEVED_
          else
            x
          end
        end
      end
    end
  end
end
# #tombstone: `mutate_syntax_string_parts`
