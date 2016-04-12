require_relative 'test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] \"mess-with\"" do

    it "make dynamic stub proxy (the system conduit)" do

      _stub_sys = TS_::Stubs::System_Conduit_01_Hi.instance

      i, o, e, w = _stub_sys.popen3 'osascript', 'zazz'

      i and fail
      o.gets and fail
      e.gets and fail
      w.value.exitstatus.should be_zero
    end

    context "faked out kernel using etc" do

      it "`redefine_as_memoized` - definition works" do

        _ke = _kernel

        _inst = _ke.silo :Installation

        _inst.fonts_dir.should eql '/talisker'

        _inst.system_conduit.is_fake_ or fail
      end

      it "(same) - is memoized" do

        x = _inst.fonts_dir
        x or fail
        _d = x.object_id
        _inst.fonts_dir.object_id.should eql _d
      end

      it "`replace_with_partially_stubbed_proxy`" do

        _a = _inst.filesystem.glob '/talisker/*'

        _a.first.should eql '/talikser/wazoozle.dfont'
      end

      def _inst
        _kernel.silo :Installation
      end

      def _kernel
        TS_::Stubs::Kernel_01_Hi.instance
      end
    end
  end
end
