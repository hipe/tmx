require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] box" do

    context "scanner" do

      it "0" do
        scn = Home_::Box.new.get_value_stream
        expect( scn.gets ).to be_nil
        expect( scn.gets ).to be_nil
      end

      it "1" do
        box = Home_::Box.new
        box.add :foo, :bar
        scn = box.get_value_stream
        expect( scn.gets ).to eql :bar
        expect( scn.gets ).to be_nil
        expect( scn.gets ).to be_nil
      end

      it "2" do
        box = Home_::Box.new
        box.add_iambic %i( a A b B )
        scn = box.get_value_stream
        expect( scn.gets ).to eql :A
        expect( scn.gets ).to eql :B
        expect( scn.gets ).to be_nil
        expect( scn.gets ).to be_nil
      end

      it "x" do
        box = Home_::Box.new
        box.add_iambic [ :x, :foo, :y, nil, :z, :bar ]
        scn = box.get_value_stream
        expect( scn.gets ).to eql :foo
        expect( scn.gets ).to be_nil
        expect( scn.gets ).to eql :bar
        expect( scn.gets ).to be_nil
        expect( scn.gets ).to be_nil
      end
    end
  end
end
