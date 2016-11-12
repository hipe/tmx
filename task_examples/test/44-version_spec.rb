require_relative 'test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] version" do

    TS_[ self ]
    use :memoizer_methods

    it "parses the minimal case" do
      _parse "1.2"
    end

    it "parses the minimal case with patch version" do
      _parse "1.2.3"
    end

    it "parses abc1.23.45" do
      _parse "abc1.23.45"
    end

    it "parses 12.345.67abc" do
      _parse "12.345.67abc"
    end

    context "(ambiguity)" do

      shared_subject :state_ do

        _str = "abc1.2.3def4.5"
        el = Common_.test_support::Expect_Emission::EmissionLog.new
        _ = el.handle_event_selectively
        _x = _subject.parse _str, & _
        _a = el.flush_to_array
        build_common_state_ _x, _a
      end

      it "fails" do
        fails_
      end

      it "emits" do

        Expect_Event[ singleton_class ]  # wee hah

        _be_msg = match %r(\Amultiple version strings matched)

        _be_this = be_emission :error, :expression, :ambiguous do |y|
          y.fetch( 0 ).should _be_msg
        end

        only_emission.should _be_this
      end
    end

    context "when patch was present" do

      dangerous_memoize :_prototype do
        _sexp = _subject.parse 'abc-1.4.7-def'
        _sexp.child( :version_object ).fetch( 1 )
      end

      it "bump major" do
        _expect "2.4.7" do |ver|
          ver.bump! :major
        end
      end

      it "bump minor" do
        _expect "1.5.7" do |ver|
          ver.bump! :minor
        end
      end

      it "bump patch" do
        _expect "1.4.8" do |ver|
          ver.bump! :patch
        end
      end
    end

    context "when patch was absent" do

      dangerous_memoize :_prototype do
        _sexp = _subject.parse '1.2'
        _sexp.child( :version_object ).fetch( 1 )
      end

      it "bump patch" do
        _expect "1.2.1" do |ver|
          ver.bump! :patch
        end
      end
    end

    def _expect exp_s, & do_this
      _proto = _prototype
      ver = _proto.dup
      do_this[ ver ]

      exp_s == ver.unparse_to( "" ) or fail

      NIL_
    end

    def _parse str  # assumes will succeed

      sexp = _subject.parse str  # note we pass no handler

      _eek = sexp.unparse

      _eek == str or fail
    end

    def _subject
      Home_::Version
    end
  end
end
