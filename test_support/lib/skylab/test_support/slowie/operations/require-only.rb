module Skylab::TestSupport

  class Slowie

    class Operations::RequireOnly

      DESCRIPTION = -> y do
        y << "only load the test files, do not run the tests"
      end

      DESCRIPTIONS = {
        but_actually_run: NOTHING_,
        test_directory: DESCRIPTION_FOR_TEST_DIRECTORY_,
      }

      PRIMARIES = {
        but_actually_run: :__parse_but_actually_run,
        test_directory: :__parse_test_directory,
      }

      def initialize

        @_actually_run = false
        @operator_branch = Zerk_::ArgumentScanner::OperatorBranch_via_Hash[ PRIMARIES ]

        o = yield

        @_argument_scanner = o.argument_scanner

        @__mediator = o.MEDIATOR

        @_emit = o.listener

        @test_directory_collection = o.build_test_directory_collection
      end

      def execute
        if __normal
          if __resolve_test_file_stream
            __tell_mediator_what_we_are_going_to_do
            __do_something_to_each_file
          end
        else
          UNABLE_
        end
      end

      def __parse_but_actually_run
        @_argument_scanner.advance_one  # :#here
        @_actually_run = true
        ACHIEVED_
      end

      def __do_something_to_each_file

        st = remove_instance_variable :@__test_file_stream

        count = 0
        begin
          path = st.gets
          path || break
          count += 1

          @_emit.call( :data, :test_file_path ) { path }

          ::Kernel.load path  # no need ever to `require` instead (right?)

          redo
        end while above

        @_emit.call :data, :end_of_list

        @_emit.call :info, :expression, :summary do |y|
          y << "(loaded #{ count } test file#{ 's' unless 1 == count })"
        end

        NOTHING_
      end

      def __tell_mediator_what_we_are_going_to_do

        _mediator = remove_instance_variable :@__mediator

        if @_actually_run
          _mediator.receive_notification_of_intention_to_run_tests
        else
          _mediator.receive_notification_of_intention_to_require_only
        end
        NIL
      end

      def __resolve_test_file_stream

        globber_st = @test_directory_collection.to_globber_stream
        if globber_st
          @__test_file_stream = globber_st.expand_by do |globber|
            globber.to_path_stream
          end
          ACHIEVED_
        end
      end

      # == boilerplate

      def at_from_syntaxish bi
        send bi.branch_item_value
      end

      def __normal
        ok = Parse_any_remaining_[ self, @_argument_scanner ]
        remove_instance_variable :@_argument_scanner  # b.c #here
        ok && @test_directory_collection.check_for_missing_requireds
      end

      def __parse_test_directory
        @test_directory_collection.parse_test_directory
      end

      attr_reader(  # for pre-execution syntax hacks
        :operator_branch,
        :test_directory_collection,
      )
    end
  end
end
