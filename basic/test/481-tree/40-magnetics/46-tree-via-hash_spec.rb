require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - tree via hash" do

    TS_[ self ]
    use :tree

    it 'works' do

      tree = subject_module_.via :hash,

        { name: 'foo',
          children: [

            { name: 'bar' },
            { name: 'baz',
              children: [ { name: 'bizzo' } ] } ] }

      expect( tree.slug ).to eql 'foo'
      expect( tree.children_count ).to eql 2
      st = tree.to_child_stream

      node = st.gets
      expect( node.slug ).to eql 'bar'
      expect( node.to_child_stream.gets ).to be_nil

      node = st.gets
      expect( node.slug ).to eql 'baz'

      node_a = node.to_child_stream.to_a
      expect( node_a.length ).to eql 1

      node = node_a.first
      expect( node.slug ).to eql 'bizzo'
    end
  end
end
