require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] slowie - operations - list-files" do

    TS_[ self ]
    use :memoizer_methods
    use :slowie
    use :slowie_fail_fast

    it "for now (and probably always), can't list files without test directory" do

      call :list_files
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

      ca = flush_to_case_assertion

      _st = ca.flush_to_result

      _hi = _st.gets

      ca.finish

      _hi.nil? || fail
    end

    it "find self EXPLORATORY" do

      this_file = __FILE__

      _this_real_thing = ::File.dirname this_file

      call :list_files, :test_directory, _this_real_thing

      ignore_emissions_whose_terminal_channel_symbol_is :find_command_args

      ca = flush_to_case_assertion

      _st = ca.flush_to_result

      paths = _st.to_a

      ca.finish

      ( 3 .. 5 ).include? paths.length or fail

      me = ::File.basename this_file
      _found = paths.detect do |path|
        me == ::File.basename( path )
      end

      _found || fail
    end
  end
end
