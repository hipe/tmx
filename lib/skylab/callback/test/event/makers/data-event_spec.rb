require_relative '../../test-support'

module Skylab::Callback::TestSupport

  module Evnt_Clss_Fctrs_DtEvnt___  # :+#throwaway-module for below consts

    # <-

  TS_.describe "[ca] events - class factories - data event" do

    subject = -> do
      Home_::Event.data_event_class_factory
    end

    before :all do
      Some_Data_Event = subject[].new :countizzle, :objectizzle
    end

    it "loads (builds class)" do
    end

    it "easy way to build an event class that has no message proc, is OK" do
      ev = Some_Data_Event[ 43, :_hi_ ]
      ev_ = Some_Data_Event[ 43, :_hi_ ]
      ev.ok.should eql true
      ev.countizzle.should eql 43
      ev_.countizzle.should eql ev.countizzle
      ev.objectizzle.should eql :_hi_
      ( ev.object_id == ev_.object_id ).should eql false
      ev.class.should eql ev_.class
      ev.message_proc.should be_nil
    end
  end
# ->
  end
end
