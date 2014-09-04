require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph::Tell

  describe "[tm] CLI::Actions::Graph::Tell - tell the graph meaning", wip: true do

    extend TS_


    it "`foo means bar` assigns a heretofor unknown meaning (OMG OMG OMG)" do

      using_dotfile <<-O.unindent
        digraph {
          # biff : baz
        }
      O

      tell 'foo', 'means', 'bar'

      strings.join.should match( /added.+new.+meaning.+foo/ )
      names.should eql( [:infostream] )

      exp = <<-O.unindent
        digraph {
          # biff : baz
          #  foo : bar
        }
      O
      dotfile_pathname.read.should eql( exp )
    end



    it "assign a known meaning to a new value" do

      using_dotfile <<-O.unindent
        digraph {
          # success : red
        }
      O

      tell 'success', 'means', 'blue'

      strings.join.should match(/changed meaning of success from red to blue/)
      names.should eql( [:infostream] )

      exp = <<-O.unindent
        digraph {
          # success : blue
        }
      O
      dotfile_pathname.read.should eql( exp )
    end
  end
end
