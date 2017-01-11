module Skylab::Permute

  module CLI

    class Magnetics_::TokenStream_via_ArgumentArray_and_Tokenizer < Common_::Actor::Monadic

      # (the name is for self-documentation - the tokenizer is resolved internally)
      #
      # either 1) we succeed in converting a slice of the argument array into
      # a normalized stream of qualified name-value pairs or 2) something
      # extra-functional happened, like a request for help or a parse error.
      #
      # in the case of (2), we notify toplevel client of these events by
      # sending structures to it through the option parsing. in such cases
      # we MUST result in falseish. for (2), there cannot be any "commentary"
      # events emitted; the result is the stream.

      def initialize argv, & oes_p

        @argument_array = argv
        @do_mutate_argument_array = true
        @long_help_switch = LONG_HELP__
        @short_help_switch = SHORT_HELP___

        @_on_event_selectively = oes_p
      end

      LONG_HELP__ = '--help'
      SHORT_HELP___  = '-h'

      def execute

        a = @argument_array
        if a.length.zero?
          __when_no_arguments
        else
          __via_some_arguments
        end
      end

      def __via_some_arguments

        # detect any help-looking switch as a firstmost or nonfirst lastmost
        # item in the argument array, but otherwise don't (so that `-h` can
        # be used with business meaning in other contexts). if we are
        # consuming arguments, pop a rightmost found such argument IFF we did
        # not find (and shift) a leftmost such item (so that we only ever
        # consume at most one switch, and only the leftmost one). (as for
        # implementation, note we have to do the pop (if any) before we build
        # the scanner.)

        is = [ @short_help_switch, @long_help_switch ].method :include?

        argv = @argument_array

        if 1 < argv.length && is[ argv.last ] && ! is[ argv.first ]
          help_requested = true
          if @do_mutate_argument_array
            argv.pop
          end
        end

        st = Common_::Polymorphic_Stream.via_array argv
        @_st = st

        if ! help_requested && st.unparsed_exists && is[ st.current_token ]
          help_requested = true
          st.advance_one
        end

        if help_requested
          _close_parsing
          __when_help
        else
          __resolve_pair_stream
        end
      end

      def __when_no_arguments
        @_on_event_selectively.call :error, :expression, :parse_error do |y|
          y << "expecting categories and values"
        end
        UNABLE_
      end

      def __when_help
        @_on_event_selectively.call :extra_functional, :help do
          :_no_data_from_help_for_now_
        end
        NOTHING_
      end

      def __resolve_pair_stream

        _sm = Magnetics_::Tokenizer[]
        x = _sm.solve_against @_st, & @_on_event_selectively
        if x
          # (left as array for now #todo)
          _close_parsing
          x
        else
          x
        end
      end

      def _close_parsing
        st = remove_instance_variable :@_st
        if @do_mutate_argument_array
          @argument_array[ 0, st.current_index ] = EMPTY_A_
        end
        NIL
      end
    end
  end
end
