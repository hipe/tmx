require_relative 'test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] pub-sub" do

    extend TS_
    use :expect_event

    _Subject_module = -> do
      Home_::Pub_Sub
    end

    PS_Plugin = _Subject_module[]::Subscriber

    before :all do

      module PS_1

        class PS_C1 < PS_Plugin
          SUBSCRIPTIONS = [ :carbonate, :tangle ]
        end

        class PS_C2 < PS_Plugin
          SUBSCRIPTIONS = nil
        end

        class PS_C3 < PS_Plugin
          SUBSCRIPTIONS = [ :miff, :carbonate ]
        end
      end
    end

    it "every subscriber receives it" do

      carb_a = []

      _disp.accept :carbonate do | pu |
        carb_a.push pu.class
        ACHIEVED_
      end

      2 == carb_a.length or fail
      carb_a.should be_include PS_1::PS_C1
      carb_a.should be_include PS_1::PS_C3
    end

    it "you can short circuit it by resulting in false" do

      seen_count = 0

      _disp.accept :carbonate do | pu |

        seen_count += 1
        false
      end

      seen_count.should eql 1
    end

    it "if an emission is sent on a channel with no subscribers, nothing" do

      _disp.accept :warbonate do | pu |
        fail
      end
    end

    define_method :_disp, ( Callback_.memoize do

      disp = _Subject_module[]::Dispatcher.new(
        :_resc_,
        [ :carbonate, :miff, :tangle, :warbonate ] )

      disp.load_plugins_in_module PS_1
      disp
    end )
  end
end
