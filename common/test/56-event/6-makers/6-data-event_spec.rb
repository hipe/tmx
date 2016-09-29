require_relative '../../test-support'

module Skylab::Common::TestSupport

  describe "[co] event - makers - data event" do

    TS_[ self ]
    use :memoizer_methods

    subject = -> do
      Home_::Event.data_event_class_maker
    end

    before :all do
      X_e_m_DataEvent = subject[].new :countizzle, :objectizzle
    end

    it "loads (builds class)" do
    end

    context "easy way to build an event class that has no message proc, is OK" do

      shared_subject :_obj do
        X_e_m_DataEvent[ 43, :_hi_ ]
      end

      it "the custom properties are there" do
        o = _obj
        o.countizzle == 43 || fail
        o.objectizzle == :_hi_ || fail
      end

      it "by default, is OK" do
        _obj.ok || fail
      end

      it "no message proc" do
        _obj.message_proc && fail
      end
    end
  end
end
