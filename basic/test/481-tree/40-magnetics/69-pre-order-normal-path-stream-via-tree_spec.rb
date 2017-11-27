require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - pre-order normal path stream via tree" do

    TS_[ self ]
    use :tree

    it "x." do

      tree = subject_module_::Mutable.new
      tree.touch_node 'one/two'
      tree.touch_node 'three/four/five'
      tree.touch_node 'one/six'

      st = tree.to_stream_of :paths
      expect( st.gets ).to eql "one/"
      expect( st.gets ).to eql "one/two"
      expect( st.gets ).to eql "one/six"
      expect( st.gets ).to eql "three/"
      expect( st.gets ).to eql "three/four/"
      expect( st.gets ).to eql "three/four/five"
      expect( st.gets ).to be_nil
    end
  end
end
