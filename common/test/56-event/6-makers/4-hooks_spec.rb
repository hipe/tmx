require_relative '../../test-support'

module Skylab::Common::TestSupport

  describe "[co] event - makers - hooks" do

    extend TS_

    it "loads" do
      _subject_module
    end

    it "builds" do
      _class
    end

    it "`members`" do
      _class.members.should eql [ :win, :loss ]
    end

    it "2 ways to set it ; MUTABLE" do

      o = _build_guy

      o.win do
        :hi
      end

      o.win_p.call.should eql :hi

      o.on_win do
        :hey
      end

      o.win_p.call.should eql :hey

    end

    def _build_guy
      _class.new
    end

    dangerous_memoize_ :_class do

      TS_::E_M_Hooks_1 = _subject_module.new :win, :loss

    end

    it "use optional block to add more"

    def _subject_module
      Home_::Event.hooks
    end
  end
end
