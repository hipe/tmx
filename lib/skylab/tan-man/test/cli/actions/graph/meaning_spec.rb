require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph

  # Quickie enabled!

  describe "#{ TanMan::CLI::Actions::Graph }" do
    extend ::Skylab::TanMan::TestSupport::CLI::Actions::Graph


    it "`graph meaning list` lists existing meanings found in comments!!!" do

      using_dotfile <<-O.unindent
        digraph {
          # money : honey
          # funny : bunny
        }
      O

      cd dotfile_pathname.dirname do
        client.invoke ['graph', 'meaning', 'list']
      end

      names.should eql( [:paystream, :paystream, :infostream] )

      exp = <<-O.gsub( /^        /, '' )
                       money : honey
                       funny : bunny
        (while timmin graph was listing meanings: found 2 total in ./floo.dot)
      O
      strings.join.should eql( exp )
    end
  end
end
