module Skylab::TestSupport

  class Slowie

    class Operations::Counts

      DESCRIPTION = -> y do
        y  << "show a report of the number of tests per subproduct"
      end

      DESCRIPTIONS = {
        test_directory: DESCRIPTION_FOR_TEST_DIRECTORY_,
      }

      PRIMARIES = {
        test_directory: :__parse_test_directory,
      }

      def initialize

        o = yield

        @__emit = o.listener

        @syntax_front = Here_::Models_::HashBasedSyntax.new(
          o.argument_scanner, PRIMARIES, self )

        @test_directory_collection = o.build_test_directory_collection
      end

      attr_reader(  # for pre-execution syntax hacks
        :test_directory_collection,
      )

      def execute
        if __normal
          __flush_table
        else
          UNABLE_
        end
      end

      def __flush_table
        __emit_table_schema
        __flush_table_stream
      end

      def __flush_table_stream

        @test_directory_collection.to_globber_stream.map_by do |globber|

          _count = globber.to_count
          _dir = globber.directory

          [ _dir, _count ]  # follow your schema's order per #here
        end
      end

      def __emit_table_schema
        @__emit.call :data, :table_schema do
          __build_table_schema
        end
        NIL
      end

      def __build_table_schema

        Require_zerk_[]  # [tmx]

        Zerk_::CLI::Table::Models::Schema.define do |o|
          # (the below order must accord with :#here)
          o.add_field_via_normal_name_symbol :test_directory
          o.add_field_via_normal_name_symbol :number_of_test_files, :numeric
        end
      end

      # == mostly boilerplate below (here for clarity)

      def __normal
        _yes = @syntax_front.parse_arguments
        _yes &&= @test_directory_collection.check_for_missing_requireds
        _yes  # #todo
      end

      # [#tmx-006] and friends

      attr_reader(
        :syntax_front,
      )

      def parse_present_primary_for_syntax_front_via_branch_hash_value m
        send m
      end

      def __parse_test_directory
        @test_directory_collection.parse_test_directory
      end
    end
  end
end
# #tombstone (temporary): '-z', '--zero', 'display the zero values'
