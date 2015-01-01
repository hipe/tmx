module Skylab::TestSupport

  module Quickie

    self::Front__.class  # #open :+[#028]

    class Plugins::RunRecursive

      def initialize svc
        @be_verbose = false
        @fuzzy_flag = svc.build_fuzzy_flag %w( -verbose )
        @test_path_a = nil
        @svc = svc
        @y = svc.y
      end

      attr_reader :be_verbose

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      def args_moniker
        ARGS_MONIKER__
      end

      ARGS_MONIKER__ = '<path> [..]'.freeze

      def desc y
        y << "looks for test files recursively"
        y << "in the indicated path(s)" ; nil
      end

      def prepare sig
        argv = sig.input
        a, b = find_contiguous_range_of_paths argv
        if a
          idx = @fuzzy_flag.any_first_index_in_input sig
          if idx
            sig.nilify_input_element_at_index idx
            @be_verbose = true
          end
          @input_path_a = argv[ a, b ]
          argv[ a, b ] = ::Array.new b
          sig.nudge :BEGINNING, :TEST_FILES
          sig.nudge :TEST_FILES, :CULLED_TEST_FILES
          sig.nudge :CULLED_TEST_FILES, :BEFORE_EXECUTION
          sig.carry :BEFORE_EXECUTION, :EXECUTION
          sig.nudge :EXECUTION, :FINISHED
          sig
        end
      end

      Dash_ = QuicLib_::CLI_lib[].option.starts_with_dash

      def beginning_eventpoint_notify
        # at our notification of the beginning, we do the work that needs
        # to be available for the next eventpoint. if we fail to resolve the
        # test path, we must alert the system to halt normal flow by resulting
        # in false.
        ready_test_path_a
        false if false == @test_path_a
      end

      def test_files_eventpoint_notify
        # the parent node issued this eventpoint because that is how the
        # path reconciled. we should have calculated it in the previous
        # eventpoint, because we are the only ones that move the application
        # state from BEGINNING to TEST_FILES
        nil
      end

      def culled_test_files_eventpoint_notify
      end

      # ~ services that this node provides upwards (for siblings!) ~

      def get_any_test_path_a
        # assume that pathfinder worked and the eventpoint path is working..
        (( a = @test_path_a )) ? a.dup : a
      end

      def replace_test_path_s_a path_s_a
        @test_path_a = path_s_a
        CONTINUE_
      end

      def before_execution_eventpoint_notify
        # nah.
      end

    private

      def find_contiguous_range_of_paths argv
        scn = QuicLib_::Stream[ argv ]
        while (( tok = scn.gets ))
          Dash_[ tok ] or break( a = scn.index )
        end
        if a
          b = 1
          while (( tok = scn.gets ))
            Dash_[ tok ] and break
            b += 1
          end
        end
        [ a, b ]
      end

      def ready_test_path_a
        @test_path_a.nil? and @test_path_a = my_get_any_test_path_a
        nil
      end

      def my_get_any_test_path_a
        found_all = true ; lg = local_glob
        p = QuicLib_::Basic[]::String.build_proc_for_string_ends_with_string _spec_rb
        path_a = @input_path_a.reduce [] do |m, path|
          if p[ path ]
            m << path
          else
            a = ::Dir[ "#{ path }/**/#{ lg }" ]
            if a.length.zero?
              files_not_found path
              found_all &&= false
            else
              m.concat a.reverse  # ::Dir.glob is pre-order, we need post-order
            end
          end
          m
        end
        found_all ? path_a : false
      end

      def local_glob
        @local_glob ||= "*#{ _spec_rb }"
      end

      def _spec_rb
        TestSupport_.spec_rb
      end

      def files_not_found path
        _mkr = @svc._svc._host.moniker_
        @y << "#{ _mkr }found no #{ @local_glob } files #{
          }under \"#{ path }\""
        nil
      end
    end
  end
end
