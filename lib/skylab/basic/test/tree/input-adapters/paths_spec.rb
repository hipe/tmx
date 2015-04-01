require_relative '../test-support'

module Skylab::Basic::TestSupport::Tree_TS

  describe "[ba] tree - input adapters - hash" do

    it 'works' do

      paths = [
        'a',
        'bb/cc/dd',
        'bb/cc',
        'bb/cc/dd/ee'
      ].freeze

      node = Subject_[].via :paths, paths

      node.slug.should be_nil

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
