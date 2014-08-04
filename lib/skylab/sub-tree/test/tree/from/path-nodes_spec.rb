require_relative '../test-support'

module Skylab::SubTree::TestSupport::Tree::From_PN__

  ::Skylab::SubTree::TestSupport::Tree[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[st] tree from path nodes" do

    it "so what" do
      hi = Subject_[].from :path_nodes, [ path_node_one, path_node_two ]
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
      Example_Path_Node.new :hi_there
    end

    def path_node_two
      Example_Path_Node.new %i( hey there )
    end

    class Example_Path_Node

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
