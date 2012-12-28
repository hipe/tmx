require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions::Graph

  # Quickie enabled!
                                               # (we want to be sure it lazy
  describe "#{ TanMan::CLI::Actions }::Graph::Node }" do # loads itself properly
                                               # so don't load it
                                               # here in the name)

    extend TanMan::TestSupport::CLI::Actions::Graph
    context "`graph node add`" do
      it "to a empty 'digraph' -- makes up its own prototype!!" do
        using_dotfile 'digraph{}'
        invoke_from_dotfile_dir 'graph', 'node', 'add', 'foo'
        dotfile_pathname.read.should eql( 'digraph{foo [label=foo]}' )
      end

      it "to a digraph with a prototype - it adds that puppy" do
        using_dotfile <<-O.unindent
          digraph {
          /*
            example stmt_list:
              foo -> bar
              biff -> baz

            example node_stmt:
              foo [label=foo]
          */
          }
        O
        invoke_from_dotfile_dir 'graph', 'node', 'add', 'bar'
        output.lines.last.string.should match( /created node: bar/ )
        content = dotfile_pathname.read
        content.should be_include( 'bar [label=bar]' )
      end
    end

    it "`graph node list` will show you the labels of the node_stmts" do
      using_dotfile <<-O.unindent
        digraph {
          foo [label=foo]
          bar [label=bar]
          foo -> bar
        }
      O
      invoke_from_dotfile_dir 'graph', 'node', 'list'
      names.should eql( [:paystream, :paystream, :infostream] )
      exp = <<-O.gsub( /^ {10}/, '' )
          foo
          bar
      O
      strings[0..1].join.should eql( exp )
      strings.last.should match( /\b2 total\b/ )
    end

    it "`graph node rm <foo>` works" do
      using_dotfile 'digraph{ermagherd[label="berks"]}'
      invoke_from_dotfile_dir 'graph', 'node', 'rm', 'ber'
      names.should eql( [:infostream] )
      strings.last.should match( /removed node: berks/ )
    end
  end
end
