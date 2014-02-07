require_relative '../test-support'

module Skylab::GitViz::TestSupport::CLI

  describe "[gv] CLI \"hist-tree\" command" do

    extend TS__ ; use :expect

    it "help screen shows with 'ht' alias" do
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

    false and
    it "mock output screen (for now)" do
      expect_emissions_on_channel :o
      invoke 'ht', 'mock-1'
      expect "   ├it's just                          │"
      expect "   │ └funky like that                  │#{
                   } •  •• • ••  •                   "
      expect "   └everybody in the room is floating  │#{
                 }• • • • ••• •  •• •• •• •  •• •  "
      expect_succeeded
    end
  end
end
