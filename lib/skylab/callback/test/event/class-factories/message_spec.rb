require_relative '../../test-support'

module Skylab::Callback::TestSupport

  module Evnt_Clss_Fctrs_Mssg___  # :+#throwaway-module for test consts

    # <-

  TS_.describe "[ca] event - class factories - message" do

    subject = -> do
      Callback_::Event.message_class_factory
    end

    before :all do

      My_Fun_Message = subject[].new do |foo, bar|
        "ermegerd #{ ick foo } (#{ val bar })"
      end
    end

    it "loads (builds class)" do
    end

    it "is an easy way to build one-line, NOT OK message events" do

      msg = My_Fun_Message[ :_Foo_, :_Bar_ ]

      # (for now, message objects themselves are useless. once did something)

      _ev = msg.to_event

      _ev.express_into_under y=[],
        Callback_.lib_.brazen::API.expression_agent_instance

      y.should eql ["ermegerd '_Foo_' (:_Bar_)"]
    end
  end
# ->
  end
end
