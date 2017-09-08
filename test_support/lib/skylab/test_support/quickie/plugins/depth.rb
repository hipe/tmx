module Skylab::TestSupport

  module Quickie

    class Plugins::Depth

      def initialize
        o = yield  # microservice
        @_narrator = o.argument_scanner_narrator
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "only operate on spec files at depths M thru N."
        y << "floor depth M defaults to N. a spec file's depth"
        y << "is how deep its filesystem path is (in terms of"
        y << "nested directories) relative to the \"shallowest\""
        y << "spec file(s) which we designate as having a depth"
        y << "of 1. e.g \"-depth=2..3\" says \"operate on all"
        y << "spec files at depths 2 and 3, but none at depth 1"
        y << "nor at depth 4 or deeper. useful for working thru"
        y << "a test-suite one layer at a time."
      end

      def parse_argument_scanner_head feat_found
        send ( @_parse_argument_scanner_head ||= :__parse_first ), feat_found
      end

      def __parse_first feat_found
        @_parse_argument_scanner_head = :__CLOSED__or_watever__
        if __resolve_matchdata feat_found
          ok = __via_matchdata
          if ok
            @_narrator.advance_past_match remove_instance_variable :@__value_match
          end
          ok
        end
      end

      def __resolve_matchdata feat_found

        fm = feat_found.feature_match

        vm = @_narrator.procure_matching_match_after_feature_match RANGE_RX___, fm do
          '{{ feature }} must be an integer or range (had: {{ mixed_value }})'
        end
        if vm
          @__feature_match = fm
          @__matchdata = vm.mixed
          @__value_match = vm
          ACHIEVED_
        end
      end

      _DIGIT_ = '-?[0-9]+'
      RANGE_RX___ = /\A
        (?: (?<min>#{ _DIGIT_ })  (?:-|\.\.)   )?
        (?<max>#{ _DIGIT_ })
      \z/x

      def __via_matchdata
        min_s, max_s = remove_instance_variable( :@__matchdata ).captures
        max = max_s.to_i
        min = min_s ? min_s.to_i : max
        if 0 > min
          _no { "{{ feature }} min must be non-negative (had: #{ min })" }
        elsif 0 > max
          _no { "{{ feature }} max must be non-negative (had: #{ max })" }
        elsif min > max
          _no { "{{ feature }} min must be less than or equal to max #{
            }(min: #{ min }, max: #{ max })" }
        else
          @_range = ::Range.new min, max
          ACHIEVED_
        end
      end

      def release_agent_profile
        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :files_stream
        end
      end

      def invoke _

        if @_range.end.zero?
          __a_depth_of_zero_always_filters_out_all_spec_files
          _stop
        elsif __determine_min_and_max
          __maybe_reduce_paths
        else
          __nothing_more_to_do_because_no_spec_files
          _stop
        end
      end

      def __a_depth_of_zero_always_filters_out_all_spec_files
        _notice { "({{ feature }} of 0 always filters out all spec files.)" }
      end

      def __nothing_more_to_do_because_no_spec_files
        _notice { "({{ feature }} will have no effect because there are no spec files.)" }
      end

      def __determine_min_and_max

        min = nil ; max = nil

        check_min = -> d do
          min = d
          check_min = -> d_ do
            min > d_ and min = d_ ; nil
          end ; nil
        end

        check_max = -> d do
          max = d
          check_max = -> d_ do
            max < d_ and max = d_ ; nil
          end ; nil
        end

        st = @_shared_datapoint_store.release_test_file_path_streamer_.call
        entry_a = []
        begin
          path = st.gets
          path || break
          d = 0 ; count = 0
          begin
            # (or use [ba] String `count_occurrences_in_string_of_string`)
            _d_ = path.index ::File::SEPARATOR, d
            _d_ || break
            count += 1
            d = _d_ + 1
            redo
          end while above
          check_min[ count ] ; check_max[ count ]
          entry_a.push Entry__.new( count, path )
          redo
        end while above

        if min || max
          @_entry_array = entry_a ; @max = max ; @min = min
          ACHIEVED_
        end
      end

      Entry__ = ::Struct.new :raw_depth, :path

      def __maybe_reduce_paths

        raw_floor = @_range.begin + @min - 1
        raw_ceiling = @_range.end + @min - 1
        num_too_shallow = num_too_deep = 0
        paths = []

        @_entry_array.each do |entry|
          raw_depth = entry.raw_depth
          if raw_ceiling < raw_depth
            num_too_deep += 1
          elsif raw_floor > raw_depth
            num_too_shallow += 1
          else
            paths.push entry.path
          end
        end

        if __express num_too_shallow, num_too_deep, raw_floor, raw_ceiling
          __do_reduce_probably num_too_shallow + num_too_deep, paths
        else
          _stop
        end
      end

      def __express lo, hi, lo_, hi_  # #[#hu-002]
        s_p_a = nil
        noun = -> d do
          r = "#{ d } spec file#{ 's' if 1 != d }"
          noun = -> d_ { "#{ d_ }" } ; r
        end
        noun_ = -> do
          r = "raw depth" ; noun_ = -> { "depth" } ; r
        end
        its = -> d do
          1 == d ? 'its' : 'their'
        end
        if lo.nonzero?
          ( s_p_a ||= [] ).push -> do
            "#{ noun[ lo ] } because of #{ its[ lo ] } #{ noun_[] } #{
             }less than #{ lo_ }"
          end
        end
        if hi.nonzero?
          ( s_p_a ||= [] ).push -> do
            "#{ noun[ hi ] } because of #{ its[ hi ] } #{ noun_[] } #{
             }greater than #{ hi_ }"
          end
        end
        if s_p_a
          _s_a = s_p_a.map( & :call )
          _notice { "(filtering out #{ _s_a * ' and ' }.)" }
          ACHIEVED_
        else
          _no { "filters nothing out. please omit this flag." }
        end
      end

      def __do_reduce_probably num_filtered_out, paths

        if num_filtered_out.zero?

          _stop  # if this filters nothing out, assume this was emitted

        elsif paths.length.zero?

          # if everything was filtered out,
          __express_everything_was_filtered
          _stop

        else
          Responses_::Datapoint.new ->{ Stream_[ paths ] }, :test_file_path_streamer
        end
      end

      def __express_everything_was_filtered
        _notice { "{{ feature }} filters out every spec file. nothing to do." }
        NIL
      end

      def _no & msg
        _no_because_by msg do |o|
          o.channel_tail :primary_parse_error
        end
      end

      def _notice & msg
        _no_because_by msg do |o|
          o.channel = [ :info, :expression, :notice ]
        end
      end

      def _no_because_by msg
        @_narrator.no_because_by do |o|
          yield o
          o.message_proc = msg
          o.feature_match = @__feature_match
        end
      end

      def _stop
        Responses_.the_stop_response
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==
      # ==
    end
  end
end
