require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - recording" do

    TS_[ self ]

    it "loads" do
      _subject_module || fail
    end

    it "whine on not absolute path" do
      against_line_ "1 class Foo x/y/zz"
      _want_whine do |y|
        y[0] == "expected path near \"x/y/zz\\n\"" || fail
      end
    end

    it "read a line for an ordinary class opening (abspath)" do
      against_line_ " 123 class Foo::Bar_123_baz /x/y/zz"
      o = _money
      _same_for_const o
      o.event_symbol == :class || fail
    end

    it "read a line for an ordinary class ending" do
      against_line_ " 123 end Foo::Bar_123_baz /x/y/zz"
      o = _money
      _same_for_const o
      o.event_symbol == :end || fail
    end

    it "read a line for a singleton class opening" do
      against_line_ "1 class «singleton class» /x/y/zz"
      o = _money
      _same_for_sing o
      o.event_symbol == :class || fail
    end

    it "read a line for a singleton class closing" do
      against_line_ "1 end «singleton class» /x/y/zz"
      o = _money
      _same_for_sing o
      o.event_symbol == :end || fail
    end

    def _same_for_const tu
      _same tu
      o = tu.receiverish
      o.is_const_module || fail
      o.is_special && fail
      o.qualified_const_symbol == :"Foo::Bar_123_baz" || fail
      o.moniker == "Foo::Bar_123_baz" || fail
    end

    def _same_for_sing tu
      _same tu
      o = tu.receiverish
      o.is_const_module && fail
      o.is_special || fail
      o.category_symbol == :singleton_class || fail
      o.moniker == "«singleton class»" || fail
    end

    def _same tu
      tu.lineno.bit_length
      tu.path || fail
    end

    def against_line_ line
      @LINE = line
    end

    def _want_whine & p
      _geld( & p )
    end

    def _money
      _geld
    end

    def _geld
      line = remove_instance_variable :@LINE
      line << NEWLINE_
      if block_given?
        log = Common_.test_support::Want_Emission::Log.for self
        _p = log.handle_event_selectively
        _x = _subject_module::Tuple_via_line__.call(
          line, X_pmods_rec_path_cache, & _p )
        _x == false || fail
        _em = log.gets
        _lines = _em.to_black_and_white_lines
        yield _lines
      else
        _subject_module::Tuple_via_line__[ line, X_pmods_rec_path_cache ]
      end
    end

    X_pmods_rec_path_cache = {}

    def _subject_module
      Home_::Models_::Recording
    end
  end
end
