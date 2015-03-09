require_relative '../../test-support'

module Skylab::GitViz::TestSupport::Models

  describe "[gv] models - hist-tree - modalities - CLI", wip: true do

    extend TS_
    use :expect_event

    it "help screen shows with 'ht' alias" do
      self._USE_expect_stdout_stderr
      invoke 'ht', '-h'
      expect :styled, %r(\Ausage: #{ PROGNAME_ } #{
        }\{hist-tree\|ht\} .*\[<path>\]\z)
      expect_blank_line
      expect :styled, %r(\Adescription: fun\b.+\bon a git-versioned filetree\b)
      expect_blank_line
      expect :styled, %r(\Aoptions\z)
      while @baked_em_a.length.nonzero?
        expect :styled, %r(\A {2,}-)
      end
      expect_succeeded
    end

    it "see dots (mocked)" do
      _path = '/derp/berp/dirzo'
      invoke 'ht', _path, '--use-mocks'
      expect_information_about_moves
      expect_dots
      expect_succeeded
    end

    def expect_information_about_moves
      expect_emissions_on_channel :e
      2.times do
        expect %r(\bappears\b.+informational\b)
      end
    end

    def expect_dots
      expect_emissions_on_channel :o
      expect " ├everybody in the room is floating  │ •• "
      expect " ├it's just                          │"
      expect " │ └funky like that                  │• • "
      expect " └move-after                         │   •"
    end
  end
end
