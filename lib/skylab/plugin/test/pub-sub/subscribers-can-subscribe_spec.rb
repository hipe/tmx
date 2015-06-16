require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] pub-sub - subscribers can subscribe other subscribers" do

    extend TS_
    use :expect_event

    _Subject_module = -> do
      Home_::Pub_Sub
    end

    it "like so" do

      disp = nil
      mod = _Subject_module[]

      pu1 = mod::Subscriber.new_via_resources :x
      pu2 = mod::Subscriber.new_via_resources :x

      pu1.subscription_name_symbols = [ :blerkins ]
      pu1.on_event_selectively = -> do
        disp.receive_plugin pu2
        true
      end

      pu2.subscription_name_symbols = [ :jerkins ]
      pu2.on_event_selectively = :_abuse_

      disp = mod::Dispatcher.new( :_resc_, [ :jerkins, :blerkins ] )

      disp.receive_plugin pu1

      disp.accept :jerkins do | pu |
        fail
      end

      disp.accept :blerkins do | pu |
        pu.on_event_selectively[]
      end

      x = nil
      disp.accept :jerkins do | pu |
        x = pu.on_event_selectively
        true
      end

      x.should eql :_abuse_
    end
  end
end

