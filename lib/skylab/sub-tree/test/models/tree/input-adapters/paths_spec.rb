require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_Tree

  describe "[st] models - tree - input adapters - hash" do

    it 'works' do

      paths = [
        'a',
        'bb/cc/dd',
        'bb/cc',
        'bb/cc/dd/ee'
      ].freeze

      node = Subject_[].from :paths, paths

      node.has_slug.should be_nil

      node.children_count.should eql 2

      st = node.to_child_stream

      node = st.gets
      node.slug.should eql 'a'
      node.children_count.should be_zero

      node = st.gets
      node.slug.should eql 'bb'
      node.children_count.should eql 1

      st.gets.should be_nil

      node = node.fetch_first_child
      node.slug.should eql 'cc'

      node.children_count.should eql 1
      node = node.child_at_position 0

      node.slug.should eql 'dd'
      node.children_count.should eql 1
      node = node.fetch_first_child

      node.slug.should eql 'ee'
    end
  end
end
