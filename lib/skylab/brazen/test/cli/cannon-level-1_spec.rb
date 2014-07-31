require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI cannon level 1" do

    extend TS_

    # it "  0)  no arguments"

    # it "1.1)  strange argument"

    it "1.2)  strange option" do
      invoke 'st', '-z'
      expect 'invalid option: -z'
      expect_invite_line
      expect_errored
    end

    # it "1.3)  good argument"

    it "1.4)  good option" do
      invoke 'st', '-h'
      expect :styled, /\Ausage: bzn status \[-v\] .*\[<path>\]\z/
      expect %r(\A[ ]{7}bzn status -h\z)
      expect_maybe_a_blank_line
      expect :styled, /\Adescription: get status of a workspace\b/
      expect_maybe_a_blank_line
      expect_header_line 'options'
      expect %r(\A[ ]{4}-v, --verbose)
      expect %r(\A[ ]{4}-h, --help[ ]{23}this screen\z)
      expect_maybe_a_blank_line
      expect_header_line 'argument'
      expect %r(\A[ ]{4}path[ ]{29}the location of the workspace)
      expect :styled, /\A[ ]{37}it's really neat\z/
      expect_succeeded
    end

    # ~ business

    def expect_invite_line
      expect :styled, /\Ause '?bzn status -h'? for help\z/
    end
  end
end
