require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_Tree::IA_PNP

  ::Skylab::SubTree::TestSupport::Models_Tree[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[st] models - tree - input adapters - node identifiers" do

    it "works" do

      hi = Subject_[].from :node_identifiers, [ path_node_one, path_node_two ]
      hi.children_count.should eql 2
      one, two = hi.children.to_a
      one.slug.should eql "hi_there"
      one.node_payload.wazoozle.should eql 'HI_THERE'

      two.slug.should eql :hey
      x = two.children.first
      x.slug.should eql :there
      two.node_payload.should be_nil
      x.node_payload.wazoozle.should eql 'HEY THERE'
    end

    def path_node_one
      Example_Identifier_Node.new :hi_there
    end

    def path_node_two
      Example_Identifier_Node.new %i( hey there )
    end

    class Example_Identifier_Node

      def initialize x
        @x = x
      end

      def to_tree_path
        ::Array.try_convert( @x ) ? @x.dup : @x
      end

      def wazoozle
        "#{ [ * @x ] * ' ' }".upcase
      end
    end
  end
end
