require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] slowie - operations - list-files" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :slowie

    it "for now (and probably always), can't list files without test directory" do

      call :list_files
      ignore_these_common_emissions_
      fails_because_no_test_directories_ :list_files
    end

    it "test directory no ent EXPLORATORY" do

      _test_directory_no_exist = Home_::Fixtures.directory :not_here

      call :list_files, :test_directory, _test_directory_no_exist

      ev = nil
      expect :info, :event, :find_command_args do |ev_|
        ev = ev_
      end

      ev2 = nil
      expect :error, :find_error do |ev_|
        ev2 = ev_
      end

      ignore_these_common_emissions_

      _hi = finish_by do |st|
        st.gets
      end

      _hi.nil? || fail
    end

    it "find self EXPLORATORY" do

      this_file = __FILE__

      _this_real_thing = ::File.dirname this_file

      call :list_files, :test_directory, _this_real_thing

      ignore_these_common_emissions_

      ignore_emissions_whose_terminal_channel_symbol_is :find_command_args

      paths = finish_by do |st|
        st.to_a
      end

      ( 3 .. 5 ).include? paths.length or fail

      me = ::File.basename this_file
      _found = paths.detect do |path|
        me == ::File.basename( path )
      end

      _found || fail
    end
  end
end
