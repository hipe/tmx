require_relative 'test-support'

module Skylab::TestSupport::TestSupport::DocTest::CLI

  describe "[ts] doc-test integration: CLI generate" do

    extend TS_

    it "0.0) no args" do
      invoke 'genera'
      on_stream :errput
      expect "couldn't generate test document because no line upstream"
      expect :styled, %r(\Ause '?ts-dt generate -h'? for help\b)i
      expect_failed
    end

    it "1.4) help" do
      invoke 'gen', '-h'
      on_stream :errput
      expect :styled, %r(\Ausage: ts-dt generate \[)i
      string = get_string_for_contiguous_lines_on_stream :errput
      string.should be_include '-o, --output-adapter ADAPTER'
      _d = count_occurrences_of_newlines_in_string string
      ( 16 .. 20 ).should be_include _d

      @exitstatus.should be_zero
    end

    it "1.1) no ent" do
      invoke 'generate', a_path_for_a_file_that_does_not_exist
      on_stream :errput
      expect %r(\Acouldn't generate .+ because no such file or direc.+not-exi)i
      @exitstatus.should equal_generic_error
    end

    def a_path_for_a_file_that_does_not_exist
      TestSupport_.dir_pathname.join( 'does-not-exist.rb' ).to_path
    end

    it "1.3) money" do

      td = TestSupport_::Lib_::System[].filesystem.tmpdir.new(
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      td = td.tmpdir_via_join 'td-ohai'
      td.prepare
      _opath = td.join( 'ts-dt-output.roobie' ).to_path

      invoke 'generate', the_main_real_file_doctestable_file_path, '--output-path', _opath

      @output_s = ::File.read _opath
      _d = count_occurrences_of_newlines_in_string @output_s
      ( 42 .. 46 ).should be_include _d
      @exitstatus.should be_zero

      ::File.unlink _opath
    end
  end
end
