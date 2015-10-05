require_relative 'test-support'

module Skylab::TestSupport::TestSupport::DocTest::CLI

  describe "[ts] doc-test integration: CLI recursive" do

    extend TS_

    # three laws compliant.

    it "loads" do
      _CLI_module
    end

    it "pings" do
      invoke 'ping'
      on_stream :output
      expect :styled, 'ping !'
      expect_no_more_lines
      @exitstatus.should eql :_hello_from_doc_test_
    end

    it "list", wip: true do
      invoke 'recursive', '--sub-act', 'list', common_path
      on_stream :output
      expect %r(\A/.+/doc-test/core\.rb[ ]{2}#output-filename:inte)
      expect %r(\A/)
      expect :errput, '(2 manifest entries total)'
      expect_no_more_lines
      @exitstatus.should be_zero
    end

    _preview_done_rx = %r(\A\(preview for one file done \(\d+ lines)

    _NOUN_STEM = 'test document generation'

    it "does the dry run that generates fake bytes omg", wip: true do

      invoke 'recursive', '--sub-act', 'preview', common_path

      on_stream :errput

      expect  %r(\Acurrent output path -)

      _d = count_contiguous_lines_on_stream :output
      ( 29 .. 33 ).should be_include _d

      expect _preview_done_rx
      expect %r(\Acurrent output path -)

      _d = count_contiguous_lines_on_stream :output
      ( 45 .. 49 ).should be_include _d

      expect _preview_done_rx
      expect "(2 #{ _NOUN_STEM }s total)"

      expect_no_more_lines

      @exitstatus.should be_zero
    end

    it "requires force to overwrite", wip: true do

      invoke 'recursive', '--dry-run', common_path

      on_stream :errput

      expect :styled, /\Acouldn't .+ generate .+ because .+ exists, won't/
      expect "(0 #{ _NOUN_STEM }s total)"
      expect_no_more_lines

    end

    it "money", wip: true do

      invoke 'recursive', '--forc', '--dry-run', common_path

      on_stream :errput
      expect %r(\Aupdating [^ ]+/final/top_spec\.rb \.\. done \(\d+ lines\b)
      expect %r(\Aupdating [^ ]+/integration/core_spec\.rb \.\. done \(\d+ lines\b)
      expect "(2 #{ _NOUN_STEM }s total)"
      expect_no_more_lines

    end

    def common_path
      Subject_[].dir_pathname.to_path
    end
  end
end