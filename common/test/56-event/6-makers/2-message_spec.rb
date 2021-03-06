require_relative '../../test-support'

module Skylab::Common::TestSupport

  module Evnt_Clss_Fctrs_Mssg___  # :+#throwaway-module for test consts

    # <-

  TS_.describe "[co] event - makers - message" do

    subject = -> do
      Home_::Event.message_class_maker
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
        Home_.lib_.brazen::API.expression_agent_instance

      expect( y ).to eql ["ermegerd '_Foo_' (:_Bar_)"]
    end
  end
# ->
  end
end
