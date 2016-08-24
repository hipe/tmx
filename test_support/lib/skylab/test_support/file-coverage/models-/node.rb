module Skylab::TestSupport

  module FileCoverage

    class Models_::Node

      attr_reader(
        :asset_dir_entry_s_a, :asset_file_entry_s_a,
        :has_assets, :has_tests,
        :test_dir_entry_s_a, :test_file_entry_s_a )

      # ~

      def merge_destructively otr

        Home_.lib_.basic::Tree.merge_destructively.via_ivars(
          otr, self, :@asset_dir_entry_s_a, :@asset_file_entry_s_a,
            :@has_assets, :@has_tests,
            :@test_dir_entry_s_a, :@test_file_entry_s_a )

        NIL_
      end

      # ~

      def receive_asset_dir_entry_string_ s

        @has_assets = true
        ( @asset_dir_entry_s_a ||= [] ).push s
        NIL_
      end

      def receive_asset_file_entry_string_ s

        @has_assets = true
        ( @asset_file_entry_s_a ||= [] ).push s
        NIL_
      end

      def receive_test_dir_entry_string_ s

        @has_tests = true
        ( @test_dir_entry_s_a ||= [] ).push s
        NIL_
      end

      def receive_test_file_entry_string_ s

        @has_tests = true
        ( @test_file_entry_s_a ||= [] ).push s
        NIL_
      end

    end
  end
end
