require_relative 'test-support'

module Skylab::Brazen::TestSupport::CLI

  describe "[br] CLI cannon level 1" do

    extend TS_

    # it "  0)  no arguments"

    # it "1.1)  strange argument"

    it "1.2)  strange option - ( E I )" do
      invoke 'st', '-z'
      expect 'invalid option: -z'
      expect_invite_line
      expect_errored
    end

    # it "1.3)  good argument"

    it "1.4)  good option (help screen)" do
      invoke 'st', '-h'
      expect_help_screen_first_half
      expect_header_line 'argument'
      expect %r(\A[ ]{4}path[ ]{29}the location of the workspace)
      expect :styled, /\A[ ]{37}it's really neat\z/
      expect_maybe_a_blank_line
      expect_header_line 'environment variable'
      expect %r(\A[ ]{4}BRAZEN_MAX_NUM_DIRS[ ]{14}how far up )
      expect_succeeded
    end

    it "2)    extra argument - ( E U I )" do
      invoke 'st', 'wing', 'wang'
      expect :styled, %r(\Aunexpected argument:? ['"]?wang['"]?)
      expect_usage_line
      expect_invite_line
    end

    # ~ business


    def expect_secondary_syntax_line
      expect %r(\A[ ]{7}bzn status -h\z)
    end

    def expect_description_line
      expect :styled, /\Adescription: get status of a workspace\b/
    end

    def expect_options
      expect %r(\A[ ]{4}-v, --verbose)
      expect %r(\A[ ]{4}-h, --help[ ]{23}this screen\z)
    end

    def expect_missing_required_property i
      expect :styled, "missing required property <#{ i }>"
    end

    def expect_usage_line
      expect :styled, /\Ausage: bzn status \[-v\] .*\[<path>\]\z/
    end

    def expect_invite_line
      expect :styled, /\Ause '?bzn status -h'? for help\z/
    end
  end
end
