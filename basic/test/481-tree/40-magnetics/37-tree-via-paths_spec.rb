require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - tree via paths" do

    TS_[ self ]
    use :tree

    it 'works' do

      paths = [
        'a',
        'bb/cc/dd',
        'bb/cc',
        'bb/cc/dd/ee'
      ].freeze

      node = subject_module_.via :paths, paths

      expect( node.slug ).to be_nil

      expect( node.children_count ).to eql 2

      st = node.to_child_stream

      node = st.gets
      expect( node.slug ).to eql 'a'
      expect( node.children_count ).to be_zero

      node = st.gets
      expect( node.slug ).to eql 'bb'
      expect( node.children_count ).to eql 1

      expect( st.gets ).to be_nil

      node = node.fetch_first_child
      expect( node.slug ).to eql 'cc'

      expect( node.children_count ).to eql 1
      node = node.child_at_position 0

      expect( node.slug ).to eql 'dd'
      expect( node.children_count ).to eql 1
      node = node.fetch_first_child

      expect( node.slug ).to eql 'ee'
    end
  end
end
