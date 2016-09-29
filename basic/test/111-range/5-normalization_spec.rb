require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] range normalization" do

    TS_[ self ]
    use :expect_event

    it "outside left" do

      _against( -2 )
      _expect_common_failure(
        "'argument' must be between -1 and 2 inclusive. had -2" )
    end

    it "outside right" do

      _against 3
      _expect_common_failure %r(inclusive\. had 3\z)
    end

    it "inside" do

      _against( -1 )

      expect_no_events

      _kn = @result
      _kn.is_known_known or fail
      -1 == _kn.value_x or fail
    end

    def _against x

      @result = _subject_call(
        :begin, -1,
        :end, 2,
        :x, x,
        & handle_event_selectively_ )
      NIL_
    end

    def _subject_call * x_a, & oes_p
      _subject_module.normalization.call_via_iambic x_a, & oes_p
    end

    def _expect_common_failure x

      false == @result or fail

      _em = expect_event_ :actual_property_is_outside_of_formal_property_set

      actual_s = black_and_white _em.cached_event_value

      if x.respond_to? :ascii_only?
        actual_s.should eql x
      else
        actual_s.should match x
      end
    end

    it "curried" do

      o = __build_subject_curry
      o.against_value( 'arbie' ) or false
      o.against_value( 'foobi' ) and false
    end

    def __build_subject_curry

     _subject_module.normalization.new_with(
        :begin, 'barbie',
        :end, 'foobie',
      )
    end

    def _subject_module
      Home_::Range
    end
  end
end
