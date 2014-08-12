require_relative 'test-support'

module Skylab::Callback::TestSupport::OD__

  ::Skylab::Callback::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Subject_ = -> { Callback_::Ordered_Dictionary }

  describe "[cb] ordered dictionary" do

    before :all do
      Adapter_Listener_ = Subject_[].new :error, :info
    end

    it "normative" do
      e_a = [] ; i_a = []
      listener = Adapter_Listener_.new -> x { e_a << x }, -> x { i_a << x }
      listener.receive_error_event :x
      listener.receive_info_event :y
      listener.receive_info_event :z
      e_a.should eql [ :x ]
      i_a.should eql [ :y, :z ]
    end

    it "nil callbacks don't get called" do
      one_a = []
      listener = Adapter_Listener_.new -> x { one_a << x }
      listener.receive_error_event :a
      listener.receive_info_event :b
      one_a.should eql [ :a ]
    end

    it "you can reflect on the listeners themselves" do
      listener = Adapter_Listener_.new :foo, :bar
      listener.error_p.should eql :foo
      listener.info_p.should eql :bar
    end
  end
end
