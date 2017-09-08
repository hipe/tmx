# frozen_string_literal: true

module Skylab::TestSupport

  module Quickie

    class Plugins::Order

      def initialize
        o = yield
        @_narrator = o.argument_scanner_narrator
        @_listener = o.listener
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "(use \"#{ _moniker } help\" for help on this plugin.)"
      end

      def parse_argument_scanner_head feat_found
        send ( @_parse_argument_scanner_head ||= :__parse_first ), feat_found
      end

      def __parse_first feat_found

        # #tombstone-A.1 we used to do optional arguments differently

        @_parse_argument_scanner_head = :__CLOSED__or_watever__

        nar = @_narrator
        fm = feat_found.feature_match
        vm = nar.match_optional_argument_after_feature_match fm
        if vm
          s = vm.mixed
          nar.advance_past_match vm
        else
          s = DEFAULT__
          nar.advance_past_match fm
        end

        if 'help' == s
          __when_help
        else

          _ = Here_::Terms_via_String___[ s, & @_listener ]
          _store :@_terms, _
        end
      end

      def release_agent_profile
        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :files_stream
        end
      end

      def invoke _

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

        ok = true
        ok &&= __resolve_ordered_paths
        ok &&= __normalize_terms
        ok && __init_range
        ok && __via_ordered_paths
        if ok
          _st = Stream_[ remove_instance_variable :@__final_paths ]
          once = -> { once = nil ; _st }
          Responses_::Datapoint.new ->{once[]}, :test_file_path_streamer
        else
          Responses_.the_stop_response
        end
      end

      def __normalize_terms

        # (we can't normalize the range until
        #  we know how many paths there are.)

        x = remove_instance_variable :@_terms
        x = Here_::NormalTerms_via_Parameters___[ x, @_ordered_paths, & @_listener ]
        _store :@_terms, x
      end

      def __init_range
        o = Here_::Range_via_Terms___[ remove_instance_variable( :@_terms ) ]
        @_do_reverse = o.do_reverse
        @_range = o.range
        NIL_
      end

      def __via_ordered_paths

        slice = @_ordered_paths[ @_range ]
        if @_do_reverse
          slice.reverse!
        end
        @__final_paths = slice ; nil
      end

      def __resolve_ordered_paths

        _st = @_shared_datapoint_store.release_test_file_path_streamer_.call
        orig_paths = _st.to_a
        _st_ = Here_::OrderedPathStream_via_Paths___[ orig_paths ]
        ordered_paths = _st_.to_a
        orig_paths.length == ordered_paths.length || self._I_HAVE_MADE_A_HUGE_MI
        @_ordered_paths = ordered_paths ; ACHIEVED_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- Help --

      def __when_help
        io = @_listener.call :resource, :line_downstream_for_help
        io and __express_help io
      end

      def __express_help io
        _y = ::Enumerator::Yielder.new( & io.method( :puts ) )
        Here_::ExpressHelp_via_Parameters___[ _y, DEFAULT__, _moniker ]
        NOTHING_
      end

      def _moniker
        '-order'
      end

      Here_ = self
      DEFAULT__ = '1-N'
    end
  end
end
# #tombstone-A.1: we used to do optional arguments by hand
