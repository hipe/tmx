require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - tree via node identifiers" do

    TS_[ self ]
    use :tree

    it "works" do

      hi = subject_module_.via :node_identifiers, [ path_node_one, path_node_two ]
      expect( hi.children_count ).to eql 2
      one, two = hi.to_child_stream.to_a
      expect( one.slug ).to eql "hi_there"
      expect( one.node_payload.wazoozle ).to eql 'HI_THERE'

      expect( two.slug ).to eql :hey
      x = two.fetch_first_child
      expect( x.slug ).to eql :there
      expect( two.node_payload ).to be_nil
      expect( x.node_payload.wazoozle ).to eql 'HEY THERE'
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
