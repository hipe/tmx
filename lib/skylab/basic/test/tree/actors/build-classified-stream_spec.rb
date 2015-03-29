require_relative '../test-support'

module Skylab::SubTree::TestSupport::Models_Tree

  describe "[st] models - tree - actors - build traversal stream" do

    extend TS_

    it "3 node triangle" do

      tree = fp 'a/b', 'a/c'
      tree = tree.fetch_only_child  # only because 'a' is only child above

      st = tree.to_classified_stream

      cx = st.gets
      cx.node.slug.should eql 'a'
      cx.depth.should eql 0
      cx.is_first.should eql true
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'b'
      cx.depth.should eql 1
      cx.is_first.should eql true
      cx.is_last.should eql false

      cx = st.gets
      cx.node.slug.should eql 'c'
      cx.depth.should eql 1
      cx.is_first.should eql false
      cx.is_last.should eql true

      st.gets.should be_nil

    end

    it "3 node beanstalk" do

      tree = fp 'a/b/c'
      tree = tree.fetch_only_child  # ditto

      st = tree.to_classified_stream

      cx = st.gets
      cx.node.slug.should eql 'a'
      cx.depth.should be_zero
      cx.is_first.should eql true
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'b'
      cx.depth.should eql 1
      cx.is_first.should eql true
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'c'
      cx.depth.should eql 2
      cx.is_first.should eql true
      cx.is_last.should eql true

      st.gets.should be_nil
    end

    it "5 point valley" do

      tree = fp 'a/b', 'c', 'd/e'
      st = tree.to_classified_stream

      cx = st.gets
      cx.node.has_slug.should be_nil
      cx.depth.should eql 0
      cx.is_first.should eql true
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'a'
      cx.depth.should eql 1
      cx.is_first.should eql true
      cx.is_last.should eql false

      cx = st.gets
      cx.node.slug.should eql 'b'
      cx.depth.should eql 2
      cx.is_first.should eql true
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'c'
      cx.depth.should eql 1
      cx.is_first.should eql false
      cx.is_last.should eql false

      cx = st.gets
      cx.node.slug.should eql 'd'
      cx.depth.should eql 1
      cx.is_first.should eql false
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'e'
      cx.depth.should eql 2
      cx.is_first.should eql true
      cx.is_last.should eql true

      st.gets.should be_nil

    end

    it "4 point mountain" do

      tree = fp 'a', 'b/c', 'd'
      st = tree.to_classified_stream

      cx = st.gets
      cx.node.has_slug.should be_nil
      cx.depth.should eql 0

      cx = st.gets
      cx.node.slug.should eql 'a'
      cx.depth.should eql 1
      cx.is_first.should eql true
      cx.is_last.should eql false

      cx = st.gets
      cx.node.slug.should eql 'b'
      cx.depth.should eql 1
      cx.is_first.should eql false
      cx.is_last.should eql false

      cx = st.gets
      cx.node.slug.should eql 'c'
      cx.depth.should eql 2
      cx.is_first.should eql true
      cx.is_last.should eql true

      cx = st.gets
      cx.node.slug.should eql 'd'
      cx.depth.should eql 1
      cx.is_first.should eql false
      cx.is_last.should eql true

      st.gets.should be_nil
    end
  end
end
