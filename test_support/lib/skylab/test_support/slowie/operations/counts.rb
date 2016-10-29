module Skylab::TestSupport

  class Slowie

    class Operations::Counts

      if false
        y  <<  "show a report of the number of tests per subproduct"
      end

      def initialize
        o = yield
        @argument_scanner = o.argument_scanner
        @_emit = o.listener
        @globberer_by = o.method :globberer_by

        @_test_directory_collection = Here_::Models_::TestDirectoryCollection.
          new :counts, o
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

        __globber_stream.map_by do |globber|

          _count = globber.to_count
          _dir = globber.directory

          [ _dir, _count ]  # follow your schema's order per #here
        end
      end

      def __globber_stream  # copy-pasted (at writing) for clarity

        globberer = @globberer_by.call do |o|
          o.xx_example_globber_option_xx = :yy
        end

        @_test_directory_collection.to_nonempty_test_directory_stream.map_by do |dir|
          globberer.globber_via_directory dir
        end
      end

      # ~

      def __emit_table_schema
        @_emit.call :data, :table_schema do
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

      # -- parsing arguments (do it yourself for clarity & flexibility)

      def __normal
        if __parse_args
          @_test_directory_collection.check_for_missing_requireds
        end
      end

      def __parse_args
        ok = true
        until @argument_scanner.no_unparsed_exists
          ok = __parse_primary
          ok || break
        end
        ok
      end

      def __parse_primary
        m = @argument_scanner.match_head_against_primaries_hash PRIMARIES___
        if m
          send m
        end
      end

      PRIMARIES___ = {
        test_directory: :__parse_test_directory,
      }

      def __parse_test_directory
        @_test_directory_collection.parse_test_directory
      end
    end
  end
end
# #tombstone (temporary): '-v', '--verbose', 'show max share meter (experimental)'
# #tombstone (temporary): '-z', '--zero', 'display the zero values'
