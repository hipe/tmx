require_relative '../../test-support'

module Skylab::Common::TestSupport

  describe "[co] event - makers - hooks" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module
    end

    it "builds" do
      _class
    end

    it "`members`" do
      expect( _class.members ).to eql [ :win, :loss ]
    end

    it "2 ways to set it ; MUTABLE" do

      o = _build_guy

      o.win do
        :hi
      end

      expect( o.win_p.call ).to eql :hi

      o.on_win do
        :hey
      end

      expect( o.win_p.call ).to eql :hey

    end

    def _build_guy
      _class.new
    end

    dangerous_memoize :_class do

      X_e_m_Hooks = _subject_module.new :win, :loss
    end

    it "use optional block to add more"

    def _subject_module
      Home_::Event.hooks
    end
  end
end
