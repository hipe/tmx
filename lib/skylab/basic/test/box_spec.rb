require_relative 'test-support'

module Skylab::Basic::TestSupport::Box

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[ba] box" do

    context "scanner" do

      it "0" do
        scn = Basic::Box.new.get_value_scanner
        scn.gets.should be_nil
        scn.gets.should be_nil
      end

      it "1" do
        box = Basic::Box.new
        box.add :foo, :bar
        scn = box.get_value_scanner
        scn.gets.should eql :bar
        scn.gets.should be_nil
        scn.gets.should be_nil
      end

      it "2" do
        box = Basic::Box.new
        box.add_iambic %i( a A b B )
        scn = box.get_value_scanner
        scn.gets.should eql :A
        scn.gets.should eql :B
        scn.gets.should be_nil
        scn.gets.should be_nil
      end

      it "x" do
        box = Basic::Box.new
        box.add_iambic [ :x, :foo, :y, nil, :z, :bar ]
        scn = box.get_value_scanner
        scn.gets.should eql :foo
        scn.gets.should be_nil
        scn.gets.should eql :bar
        scn.gets.should be_nil
        scn.gets.should be_nil
      end
    end
  end
end
