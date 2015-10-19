require_relative '../test-support'

module Skylab::Callback::TestSupport

  describe "[ca] box - as" do

    extend TS_
    use :box_support

    it "entity collection" do

      _bx = subject_with_entries_ :a, :One, :b, :Two

      _col = _bx.to_collection

      st = _col.to_entity_stream

      st.gets.should eql :One
      st.gets.should eql :Two
      st.gets.should be_nil
    end
  end
end
