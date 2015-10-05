require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] dependencies - pub-sub" do

    extend TS_
    use :dependencies_support

    before :all do

      module De_Ps1

        class C1
          ROLES = nil
          SUBSCRIPTIONS = [ :carbonate, :tangle ]
        end

        class C2
          ROLES = nil
          SUBSCRIPTIONS = nil
        end

        class C3
          ROLES = nil
          SUBSCRIPTIONS = [ :miff, :carbonate ]
        end
      end
    end

    it "every subscriber receives it" do

      carb_a = []

      _disp.accept_by :carbonate do | pu |
        carb_a.push pu.class
        ACHIEVED_
      end

      2 == carb_a.length or fail
      carb_a.should be_include De_Ps1::C1
      carb_a.should be_include De_Ps1::C3
    end

    it "you can short circuit it by calling `break`" do

      seen_count = 0

      _disp.accept_by :carbonate do | pu |

        seen_count += 1
        break
      end

      seen_count.should eql 1
    end

    it "if an emission is sent on a channel with no subscribers, nothing" do

      _disp.accept_by :warbonate do | pu |
        fail
      end
    end

    dangerous_let_ :_disp do

      o = subject_class_.new
      o.emits = [ :carbonate, :miff, :tangle, :warbonate ]
      o.index_dependencies_in_module De_Ps1
      o
    end
  end
end
