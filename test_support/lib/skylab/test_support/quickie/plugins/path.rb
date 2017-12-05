module Skylab::TestSupport

  module Quickie

    class Plugins::Path

      def initialize

        o = yield  # microservice

        @_did_release = false
        @_listener = o.listener
        @_mixed_path_arguments = []  # #testpoint
        @_narrator = o.argument_scanner_narrator

        @test_filename_tail = o.test_filename_tail
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "looks for test files recursively"
        y << "in the indicated path(s)"
      end

      def parse_argument_scanner_head feat_found

        vm = @_narrator.procure_trueish_match_after_feature_match feat_found.feature_match
        if vm
          @_mixed_path_arguments.push vm.mixed
          @_narrator.advance_past_match vm
        end
      end

      def release_agent_profile
        if @_did_release
          # #coverpoint2.4 is about how a single plugin instance can
          # process multiple expressions of its argument in this manner
          NOTHING_
        else
          @_did_release = true
          Eventpoint_::AgentProfile.define do |o|
            o.must_transition_from_to :beginning, :files_stream
          end
        end
      end

      def invoke _

        # rather than validate these paths now somehow, we just whine at flush time..

        Responses_::Datapoint.new(
          method( :__to_test_file_path_stream ),
          :test_file_path_streamer,
        )
      end

      def __to_test_file_path_stream  # #testpoint

        looks_like_test = Home_.lib_.basic::String.
          build_proc_for_string_ends_with_string @test_filename_tail

        @_glob_and_moniker = "*#{ @test_filename_tail }"

        glob_tail = ::File.join '**', @_glob_and_moniker

        Stream_.call( @_mixed_path_arguments ).expand_by do |path|

          if looks_like_test[ path ]
            Common_::Stream.via_item path

          else
            _glob = ::File.join path, glob_tail
            big_list = ::Dir[ _glob ]
            if big_list.length.zero?
              __whine_about_no_ent path
              # #coverpoint2.3: no longer do we break the stream here
              Common_::THE_EMPTY_STREAM
            else
              Stream_[ big_list ]
            end
          end
        end
      end

      def __whine_about_no_ent path

        mo = @_glob_and_moniker

        @_listener.call :warning, :expression, :no_ent do |y|
          y << "no #{ mo } files in directory or no directory: #{ path }"
        end
        NIL
      end
    end
  end
end
# #history: broke out from what is now "run files"
