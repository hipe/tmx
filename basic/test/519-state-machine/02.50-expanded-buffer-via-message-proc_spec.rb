require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] state - (magnetic - ) expanded buffer via message proc" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_magnet || fail
    end

    it "money" do

      _session = _this_one_dummy_session

      _str = _call_by _session do |y|
        y << "foopie doopie"
        y << "blah blah {{ state}} blah blah."
      end

      _str == "foopie doopie<->blah blah \"chiff chaff\" blah blah." || fail
    end

    shared_subject :_this_one_dummy_session do
      _cls = _DummySession
      _sta = _state_via_name_symbol :chiff_chaff

      _cls.new _sta
    end

    def _call_by session, & p
      _ = _subject_magnet.call_by do |o|
        o.buffer = ""
        o.separator = '<->'
        o.session = session
        o.message_proc = p
      end
      _
    end

    def _state_via_name_symbol sym
      _scn = Common_::Polymorphic_Stream.via_array [ sym ]
      _sta = Home_::StateMachine::State___.
        interpret_compound_component _scn
      _sta
    end

    memoize :_DummySession do

      class X_sm_ebvmp_Session

        def initialize sta
          @state = sta
        end

        attr_reader(
          :state,
        )

        self
      end
    end
    def _subject_magnet
      Home_::StateMachine::ExpandedBuffer_via_MessageProc_
    end
  end
end
