module Skylab::TestSupport

  module Quickie

    class Plugins::RunRecursive

      def initialize adapter
        @be_verbose = false
        @fuzzy_flag = adapter.build_fuzzy_flag %w( -verbose )
        @test_path_a = nil
        @adapter = adapter
        @y = adapter.y
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
        y << "in the indicated path(s)"
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

          @_do_ping = false

          argv[ a, b ] = ::Array.new b
          sig.nudge :BEGINNING, :TEST_FILES
          sig.nudge :TEST_FILES, :CULLED_TEST_FILES
          sig.nudge :CULLED_TEST_FILES, :BEFORE_EXECUTION
          sig.carry :BEFORE_EXECUTION, :EXECUTION
          sig.nudge :EXECUTION, :FINISHED
          sig

        elsif 1 == argv.length && '-ping' == argv.first

          @_do_ping = true

          argv.clear
          sig.carry :BEGINNING, :FINISHED
          sig
        end
      end

      def beginning_eventpoint_notify

        # at our notification of the beginning, we do the work that needs
        # to be available for the next eventpoint. if we fail to resolve the
        # test path, we must alert the system to halt normal flow by resulting
        # in false.

        if @_do_ping

          @y << "hello from quickie."

          :_xx_
        else
          ready_test_path_a
          if false == @test_path_a
            false
          end
        end
      end

      def test_files_eventpoint_notify

        # the parent node issued this eventpoint because that is how the
        # path reconciled. we should have calculated it in the previous
        # eventpoint, because we are the only ones that move the application
        # state from BEGINNING to TEST_FILES

        NIL_
      end

      def culled_test_files_eventpoint_notify

        NIL_
      end

      def execution_eventpoint_notify

        @adapter.services.yes_do_execute__

        NIL_
      end

      # ~ services that this node provides upwards (for siblings!) ~

      def get_any_test_path_array
        # assume that pathfinder worked and the eventpoint path is working..
        a = @test_path_a
        if a
          a.dup
        else
          a
        end
      end

      def to_test_path_stream
        Common_::Stream.via_nonsparse_array @test_path_a
      end

      def replace_test_path_s_a path_s_a
        @test_path_a = path_s_a
        ACHIEVED_
      end

      def before_execution_eventpoint_notify
        # nah.
      end

    private

      def find_contiguous_range_of_paths argv

        scn = Common_::Stream::Magnetics::MinimalStream_via[ argv ]

        begin
          tok = scn.gets
          tok or break
          _yes = DASH_BYTE_ == tok.getbyte( 0 )
          if ! _yes
            d = scn.index
            break
          end
          redo
        end while nil

        if d
          d_ = 1
          begin
            tok = scn.gets
            tok or break
            _ok = DASH_BYTE_ == tok.getbyte( 0 )
            _ok and break
            d_ += 1
            redo
          end while nil
        end

        [ d, d_ ]
      end

      DASH_BYTE_ = DASH_.getbyte 0

      def ready_test_path_a
        @test_path_a.nil? and @test_path_a = my_get_any_test_path_a
        NIL_
      end

      def my_get_any_test_path_a

        found_all = true
        lg = local_glob

        p = Home_.lib_.basic::String.build_proc_for_string_ends_with_string(
          _spec_rb )

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
        Home_.spec_rb
      end

      def files_not_found path

        @y << "#{ @adapter.client_moniker }found no #{ @local_glob } files #{
          }under \"#{ path }\""

        NIL_
      end
    end
  end
end
