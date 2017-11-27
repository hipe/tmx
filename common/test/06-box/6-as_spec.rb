require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] box - as" do

    TS_[ self ]
    use :box_support

    it "entity collection" do

      _bx = subject_with_entries_ :a, :One, :b, :Two

      _col = _bx.to_collection

      st = _col.to_entity_stream

      expect( st.gets ).to eql :One
      expect( st.gets ).to eql :Two
      expect( st.gets ).to be_nil
    end
  end
end
