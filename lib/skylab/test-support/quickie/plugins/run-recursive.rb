module Skylab::TestSupport

  module Quickie

    class Plugins::RunRecursive

      def initialize svc
        @be_verbose = false
        @test_path_a = nil
        @svc = svc
        @y = svc.y
      end

      attr_reader :be_verbose

      def opts_moniker
        '-v'
      end
      Match_ = Index_[ '--verbose' ]

      def args_moniker
        ARGS_MONIKER_
      end

      ARGS_MONIKER_ = '<path> [..]'.freeze

      def desc y
        y << "looks for test files recursively"
        y << "in the indicated path(s)"
        nil
      end

      def prepare sig
        argv = sig.input
        a, b = find_contiguous_range_of_paths argv
        if a
          if (( idx = Match_[ sig.input ] ))
            sig.input[ idx ] = nil
            @be_verbose = true
          end
          @input_path_a = argv[ a, b ]
          argv[ a, b ] = ::Array.new b
          sig.nudge :BEGINNING, :TEST_FILES
          sig.nudge :TEST_FILES, :BEFORE_EXECUTION
          sig.carry :BEFORE_EXECUTION, :EXECUTION
          sig.nudge :EXECUTION, :FINISHED
          sig
        end
      end

      Dash_ = Headless::CLI::Option::FUN.starts_with_dash

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

      # ~ services that this node provides upwards (for siblings!) ~

      def get_any_test_path_a
        # assume that pathfinder worked and the eventpoint path is working..
        (( a = @test_path_a )) ? a.dup : a
      end

      def before_execution_eventpoint_notify
        # nah.
      end

    private

      def find_contiguous_range_of_paths argv
        scn = Basic::List::Scanner[ argv ]
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
        p = Basic::String::FUN.string_is_at_end_of_string_curry[ _spec_rb ]
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
        TestSupport::FUN._spec_rb[]
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
