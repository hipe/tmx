require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_Tree

  describe "[st] models - tree - input adapters - hash" do

    it 'works' do

      tree = Subject_[].from :hash,

        { name: 'foo',
          children: [

            { name: 'bar' },
            { name: 'baz',
              children: [ { name: 'bizzo' } ] } ] }

      tree.slug.should eql 'foo'
      tree.children_count.should eql 2
      st = tree.to_child_stream

      node = st.gets
      node.slug.should eql 'bar'
      node.to_child_stream.gets.should be_nil

      node = st.gets
      node.any_slug.should eql 'baz'

      node_a = node.children.to_a
      node_a.length.should eql 1

      node = node_a.first
      node.last_isomorphic_key.should eql 'bizzo'
    end
  end
end
