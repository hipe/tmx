require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] output adapters - quickie (and o.a's in general)" do

    TS_[ self ]
    # use :expect_event
    # use :expect_line

    # (will rewrite or #todo sunset)

    it "loads" do
      _subject
    end

    it "other", wip: true do
      ::Kernel._K
    end

    def _subject
      output_adapters_module_::Quickie
    end
  end
end
