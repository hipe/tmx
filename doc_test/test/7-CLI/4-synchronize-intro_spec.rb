require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] CLI - synchronize intro" do

    TS_[ self ]
    use :CLI

    it "0.0) no args", wip: true do
      invoke 'genera'
      on_stream :errput
      expect "couldn't generate test document because no line upstream"
      expect :styled, %r(\Ause '?ts-dt generate -h'? for help\b)i
      expect_failed
    end

    it "1.4) help", wip: true do
      invoke 'gen', '-h'
      on_stream :errput
      expect :styled, %r(\Ausage: ts-dt generate \[)i
      string = flush_to_string_contiguous_lines_on_stream :errput
      string.should be_include '-o, --output-adapter ADAPTER'
      _d = count_occurrences_of_newlines_in_string string
      ( 21 .. 25 ).should be_include _d

      @exitstatus.should be_zero
    end

    it "1.1) no ent", wip: true do
      invoke 'generate', noent_path_
      on_stream :errput
      expect %r(\Acouldn't generate .+ because no such file or direc.+noent\.f)i
      @exitstatus.should equal_generic_error
    end

    it "1.3) money", wip: true do

      td = Home_.lib_.system.filesystem.tmpdir.new_with(
        :be_verbose, do_debug,
        :debug_IO, debug_IO )

      td = td.tmpdir_via_join 'td-ohai'
      td.prepare
      _opath = td.join( 'ts-dt-output.roobie' ).to_path

      invoke 'generate', the_main_real_file_doctestable_file_path, '--output-path', _opath

      @output_s = ::File.read _opath
      _d = count_occurrences_of_newlines_in_string @output_s
      ( 29 .. 33 ).should be_include _d
      @exitstatus.should be_zero

      ::File.unlink _opath
    end
  end
end