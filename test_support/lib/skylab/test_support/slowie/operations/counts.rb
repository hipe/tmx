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

        @operator_branch = Zerk_::ArgumentScanner::OperatorBranch_via_Hash[ PRIMARIES ]

        o = yield

        @__argscn = o.argument_scanner
        @__emit = o.listener

        @test_directory_collection = o.build_test_directory_collection
      end

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

        _Tabular = Home_.lib_.tabular

        _Tabular::Models::TableSchema.define do |o|
          # (the below order must accord with :#here)
          o.add_field_via_normal_name_symbol :test_directory
          o.add_field_via_normal_name_symbol :number_of_test_files, :numeric
        end
      end

      # == boilerplate

      def at_from_syntaxish bi
        send bi.branch_item_value
      end

      def __parse_test_directory
        @test_directory_collection.parse_test_directory
      end

      def __normal
        _ok = Parse_any_remaining_[ self, remove_instance_variable( :@__argscn ) ]
        _ok && @test_directory_collection.check_for_missing_requireds
      end

      attr_reader(  # for pre-execution syntax hacks
        :operator_branch,
        :test_directory_collection,
      )
    end
  end
end
# #tombstone (temporary): '-z', '--zero', 'display the zero values'
