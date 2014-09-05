require_relative '../test-support'

module Skylab::TanMan::TestSupport::Kernel

  ::Skylab::TanMan::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  TestLib_ = TestLib_

  describe "[tm] kernel properties" do

    it "loads" do
      subject
    end

    context "with a subclass of the base" do

      before :all do
        class C1 < Subject_[]::Base__

          TestLib_::Entity[][ self, -> do
            j = 3
            o :memoized, -> { j += 1 }, :property, :jay

            o :memoized, -> { :base_zay }, :property, :zay
          end ]
        end
      end

      it "subclassing the base works" do
        o = C1.new
        o.retrieve_value( :jay ).should eql 4
        o.retrieve_value( :jay ).should eql 4
      end

      it "adding a config frame with extra formal properties raises arg error" do
        o = C1.new
        -> do
          o.with_frame derp: :sherp, nerp: :flerp
        end.should raise_error ::ArgumentError,
          %r(\Aunrecognized properties 'derp' and 'nerp')
      end

      it "but add one with ok formals and stack works topmost one with prop" do
        o = C1.new
        j = 6
        o_ = o.with_frame :jay, -> { "ok: #{ j += 1 }" }
        o_.retrieve_value( :jay ).should eql 'ok: 7'
        o_.retrieve_value( :jay ).should eql 'ok: 7'
        o_.retrieve_value( :zay ).should eql :base_zay
        o.retrieve_value( :jay ).should eql 4
      end
    end

    def subject
      Subject_[]
    end
    Subject_ = -> do
      TanMan_::Kernel__::Properties
    end
  end
end
