require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  # Quickie compatible.

  describe "#{ TanMan::Models::Meaning } core" do
    extend ::Skylab::TanMan::TestSupport::Models::Meaning

    it "add one before one - HERE HAVE A COMMA (this was hard) BUT IT IS MAGIC" do
                                  # client.parser.root = :node_stmt
      graph = client.parse_string <<-O.unindent
        digraph {
          barl [label=barl]
        }
      O
      stmt = graph._node_stmts.to_a.first
      alist = stmt.attr_list.content
      alist.class.should eql( TanMan::Models::DotFile::Sexps::AList ) # meh
      alist._prototype = graph.class.parse :a_list, 'a=b, c=d'
      alist.unparse.should eql( 'label=barl' )
      alist._prototype.unparse.should eql( 'a=b, c=d' )
      alist._insert_assignment! :fontname, 'Futura'
      alist.unparse.should eql('fontname=Futura, label=barl')
    end


    it "UPDATE ONE AND ADD ONE -- WHAT WILL HAPPEN!!?? - note order logic" do
      graph = client.parse_string <<-O.unindent
        digraph {
          barl [label=barl, fillcolor="too"]
        }
      O
      stmt = graph._node_stmts.to_a.first
      alist = stmt.attr_list.content
      alist.unparse.should eql( 'label=barl, fillcolor="too"' )
      attrs = [['fontname', 'Futura'], ['fillcolor', '#11c11']]
      alist._update_attributes! attrs
      alist.unparse.should eql(
        'fontname=Futura, label=barl, fillcolor="#11c11"'  )
    end
  end
end
