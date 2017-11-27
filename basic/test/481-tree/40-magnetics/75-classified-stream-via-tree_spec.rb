require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - classified stream via tree" do

    TS_[ self ]
    use :tree

    it "3 node triangle" do

      tree = via_paths_ 'a/b', 'a/c'
      tree = tree.fetch_only_child  # only because 'a' is only child above

      st = tree.to_classified_stream

      cx = st.gets
      expect( cx.node.slug ).to eql 'a'
      expect( cx.depth ).to eql 0
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'b'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql false

      cx = st.gets
      expect( cx.node.slug ).to eql 'c'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql false
      expect( cx.is_last ).to eql true

      expect( st.gets ).to be_nil

    end

    it "3 node beanstalk" do

      tree = via_paths_ 'a/b/c'
      tree = tree.fetch_only_child  # ditto

      st = tree.to_classified_stream

      cx = st.gets
      expect( cx.node.slug ).to eql 'a'
      expect( cx.depth ).to be_zero
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'b'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'c'
      expect( cx.depth ).to eql 2
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      expect( st.gets ).to be_nil
    end

    it "5 point valley" do

      tree = via_paths_ 'a/b', 'c', 'd/e'
      st = tree.to_classified_stream

      cx = st.gets
      expect( cx.node.slug ).to be_nil
      expect( cx.depth ).to eql 0
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'a'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql false

      cx = st.gets
      expect( cx.node.slug ).to eql 'b'
      expect( cx.depth ).to eql 2
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'c'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql false
      expect( cx.is_last ).to eql false

      cx = st.gets
      expect( cx.node.slug ).to eql 'd'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql false
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'e'
      expect( cx.depth ).to eql 2
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      expect( st.gets ).to be_nil

    end

    it "4 point mountain" do

      tree = via_paths_ 'a', 'b/c', 'd'
      st = tree.to_classified_stream

      cx = st.gets
      expect( cx.node.slug ).to be_nil
      expect( cx.depth ).to eql 0

      cx = st.gets
      expect( cx.node.slug ).to eql 'a'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql false

      cx = st.gets
      expect( cx.node.slug ).to eql 'b'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql false
      expect( cx.is_last ).to eql false

      cx = st.gets
      expect( cx.node.slug ).to eql 'c'
      expect( cx.depth ).to eql 2
      expect( cx.is_first ).to eql true
      expect( cx.is_last ).to eql true

      cx = st.gets
      expect( cx.node.slug ).to eql 'd'
      expect( cx.depth ).to eql 1
      expect( cx.is_first ).to eql false
      expect( cx.is_last ).to eql true

      expect( st.gets ).to be_nil
    end
  end
end
