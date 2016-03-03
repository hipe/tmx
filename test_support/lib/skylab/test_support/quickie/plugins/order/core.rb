module Skylab::TestSupport

  module Quickie

    class Plugins::Order

      def initialize adapter

        @_adapter = adapter
        @_switch = adapter.build_optional_arg_switch FLAG__
      end

      def opts_moniker
      end

      def args_moniker
        ARGS_MONIKER__
      end

      FLAG__ = '-order'.freeze

      ARGS_MONIKER__ = "#{ FLAG__ }=M-N"

      DEFAULT__ = '1-N'

      def desc y
        y << "(use \"#{ _flag }=help\")"
      end

      def prepare sig

        match = @_switch.any_first_match_in_input sig
        if match

          @_argument_value = match.matchdata[ :value ]  # nil or empty s or etc
          @_index = match.index
          @_request = sig

          ___via_index_prepare  # result is sig
        else
          NIL_
        end
      end

      def ___via_index_prepare

        s = remove_instance_variable :@_argument_value

        if ! s
          s = DEFAULT__
        end

        if s.length.zero?

          __when_flag_does_not_have_an_argument

        elsif 'help' == s
          __when_help

        else

          @_argument_string = s
          __via_argument_string
        end
      end

      def __when_flag_does_not_have_an_argument

        _y << "#{ _flag } argument (if any) must be nonzero in length"
        _invite_to_me

        NIL_
      end

      # -- Parse --

      def __via_argument_string

        _ok = ___resolve_terms
        _ok && __via_terms
      end

      def ___resolve_terms

        x = Here_::Terms_via_string___[ @_argument_string, _y ]
        if x
          @_terms = x
          ACHIEVED_
        else
          _invite_to_me
          x
        end
      end

      def _invite_to_me
        _y << "use `#{ _flag }=help` for help on this option."
      end

      def __via_terms

        sig = @_request
        sig.nilify_input_element_at_index @_index
        sig.carry :TEST_FILES, :CULLED_TEST_FILES
        sig
      end

      # -- Main --

      def test_files_eventpoint_notify

        ___init_ordered_path_stream

        # you may be thinking there's an "optimization" here that could be
        # done when you have a forwards-facing, non-comprehensive range
        # (like "3-5", as opposed to "N-1" or "1-N"): just skip over the
        # the first two items, then `gets` the three items you want,
        # then you can close the stream early. WELL keep in mind:
        #
        #   A) during the sort we already traversed the whole tree of
        #      test files anyway. `gets`-ing each item isn't allocating
        #      new memory (except for the growing array of references).
        #
        #   B) the most common use case (by far) in practice for this
        #      plugin is forwards-comprehensive ("1-N"), so we traverse
        #      the whole stream anyway.

        @_ordered_paths = remove_instance_variable( :@_ordered_path_stream ).to_a
        @_orig_paths.length == @_ordered_paths.length or self._I_HAVE_MADE_A_TE

        ok = __normalize_terms
        ok && __init_range
        ok && __via_ordered_paths
      end

      def ___init_ordered_path_stream

        @_orig_paths = @_adapter.services.get_test_path_array
        _st = Here_::Ordered_path_stream_via_paths___[ @_orig_paths ]
        @_ordered_path_stream = _st
        NIL_
      end

      def __normalize_terms

        # (we can't normalize the range until
        #  we know how many paths there are.)

        x = remove_instance_variable :@_terms
        x = Here_::Normal_terms_via_parameters___[ x, @_ordered_paths, _y ]
        if x
          @_terms = x
          ACHIEVED_
        else
          x
        end
      end

      def __init_range
        o = Here_::Range_via_terms___[ remove_instance_variable( :@_terms ) ]
        @_do_reverse = o.do_reverse
        @_range = o.range
        NIL_
      end

      def __via_ordered_paths

        slice = @_ordered_paths[ @_range ]
        if @_do_reverse
          slice.reverse!
        end
        @_adapter.replace_test_path_s_a slice  # result is result
      end

      # -- Help --

      def __when_help

        Here_::Express_help_via_parameters___[ _y, DEFAULT__, _flag ]

        sig = @_request

        sig.nilify_input_element_at_index @_index
        sig.carry :BEGINNING, :FINISHED

        sig
      end

      def beginning_eventpoint_notify
        # (when help)
        NIL_
      end

      def _y
        @_adapter.y
      end

      def _flag
        FLAG__
      end

      Here_ = self
    end
  end
end
# #pending-rename: branch down
