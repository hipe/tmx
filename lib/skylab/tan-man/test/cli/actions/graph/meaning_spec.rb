require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph

  describe "[tm] CLI::Actions ::Graph::Meaning actions:", wip: true do

    extend TanMan_::TestSupport::CLI::Actions::Graph

    it "`graph meaning list` lists existing meanings found in comments!!!" do

      using_dotfile <<-O.unindent
        digraph {
          # money : honey
          # funny : bunny
        }
      O

      invoke_from_dotfile_dir 'graph', 'meaning', 'list'

      names.should eql(  [ :paystream, :paystream, :infostream ] )

      exp = <<-O.gsub( /^        /, '' )
                       money : honey
                       funny : bunny
        (while timmin was listing graph meanings: found 2 total in ./floo.dot)
      O
      strings.join.should eql( exp )
    end

    # note the below test is here because that is where it fits taxonomically
    # although it currently reached thru the `tell` command

    it "`tell <node> is <meaning>` applies the meaning!" do

      using_dotfile <<-O.unindent
        digraph{
        # done : style=filled fillcolor="#79f234"
        fizzle [label=fizzle]
        sickle [label=sickle]
        fizzle -> sickle
        }
      O

      invoke_from_dotfile_dir 'tell', 'fizzle', 'is', 'done'
      names.should eql( [:infostream] )
      strings.first.should match(
        /on node fizzle added attributes: \[ style=filled, fillcolor=#79f234 \]/
      )
      dotfile_pathname.read.should match(
        /fizzle \[fillcolor="#79f234", label=fizzle, style=filled\]\n/
      )
    end
  end
end
