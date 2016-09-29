require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - input adapters - hash" do

    TS_[ self ]
    use :tree

    it 'works' do

      tree = subject_module_.via :hash,

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
      node.slug.should eql 'baz'

      node_a = node.to_child_stream.to_a
      node_a.length.should eql 1

      node = node_a.first
      node.slug.should eql 'bizzo'
    end
  end
end
