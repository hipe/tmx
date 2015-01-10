require_relative 'test-support'

module Skylab::Callback::TestSupport::Event::Class_Factories::MSG

  ::Skylab::Callback::TestSupport::Event::Class_Factories[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[br] events - class factories - message" do

    before :all do

      My_Fun_Message__ = Subject_[].new do |foo, bar|
        "ermegerd #{ ick foo } (#{ val bar })"
      end
    end

    it "loads (builds class)" do
    end

    it "is an easy way to build one-line, NOT OK message events" do

      msg = My_Fun_Message__[ :_Foo_, :_Bar_ ]

      # (for now, message objects themselves are useless. once did something)

      _ev = msg.to_event

      _ev.render_all_lines_into_under y=[],
        Callback_.lib_.brazen::API.expression_agent_instance

      y.should eql ["ermegerd '_Foo_' (:_Bar_)"]
    end

    Subject_ = -> do
      Callback_::Event.message_class_factory
    end
  end
end
