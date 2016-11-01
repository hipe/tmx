require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] slowie - operations - counts" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :slowie

    it "test directories are required" do
      call :counts
      fails_because_no_test_directories_ :counts
    end

    context "money" do

      it "the table schema's fields are in the expected order" do
        _table_schema_field_box.a_ == %i( test_directory number_of_test_files ) || fail
      end

      it "a schema field can express as human" do
        _table_schema_field_box.h_.fetch( :test_directory ).name.as_human == "test directory" || fail
      end

      it "two rows" do
        _rows.length == 2 || fail
      end

      it "two columns" do
        _rows.fetch( 0 ).length == 2 || fail
      end

      it "each row cel (all four) is in the correct order and has probably correct shape" do
        _rows.each do |(dir, num)|
          dir.include? ::File::SEPARATOR or fail
          0 < num || fail
        end
      end

      def _rows
        _rows_and_schema.fetch 0
      end

      def _table_schema_field_box
        _rows_and_schema.fetch( 1 ).field_box
      end

      shared_subject :_rows_and_schema do

        my_dir = ::File.dirname __FILE__
        hardcoded_other_dir = ::File.join TS_.dir_path, '20-magnetics'  # :#slowie-spot-2

        if ! ::Dir.exist? hardcoded_other_dir
          fail "whoops - this moved: #{ hardcoded_other_dir }"
        end

        call( :counts,
          :test_directory, my_dir,
          :test_directory, hardcoded_other_dir,
        )

        table_schema = nil
        expect :data, :table_schema do |ts|
          table_schema = ts
        end

        ignore_emissions_whose_terminal_channel_symbol_is :find_command_args

        _st = execute

        _rows = _st.to_a

        [ _rows, table_schema ]
      end
    end
  end
end
