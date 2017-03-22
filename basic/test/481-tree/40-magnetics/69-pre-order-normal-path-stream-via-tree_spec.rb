require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - expad - paths" do

    TS_[ self ]
    use :tree

    it "x." do

      tree = subject_module_.mutable_node.new
      tree.touch_node 'one/two'
      tree.touch_node 'three/four/five'
      tree.touch_node 'one/six'

      st = tree.to_stream_of :paths
      st.gets.should eql "one/"
      st.gets.should eql "one/two"
      st.gets.should eql "one/six"
      st.gets.should eql "three/"
      st.gets.should eql "three/four/"
      st.gets.should eql "three/four/five"
      st.gets.should be_nil
    end
  end
end
