require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] range normalization" do

    TS_[ self ]
    use :want_event

    it "outside left" do

      _against( -2 )
      _want_common_failure(
        "'argument' must be between -1 and 2 inclusive. had -2" )
    end

    it "outside right" do

      _against 3
      _want_common_failure %r(inclusive\. had 3\z)
    end

    it "inside" do

      _against( -1 )

      want_no_events

      _kn = @result
      _kn.is_known_known or fail
      -1 == _kn.value or fail
    end

    def _against x

      @result = _subject_call(
        :begin, -1,
        :end, 2,
        :x, x,
        & handle_event_selectively_ )
      NIL_
    end

    def _subject_call * x_a, & p

      _normalization_class.call_via_iambic x_a, & p
    end

    def _want_common_failure x

      false == @result or fail

      _em = want_event_ :actual_property_is_outside_of_formal_property_set

      actual_s = black_and_white _em.cached_event_value

      if x.respond_to? :ascii_only?
        expect( actual_s ).to eql x
      else
        expect( actual_s ).to match x
      end
    end

    it "curried" do

      o = __build_subject_curry
      o.against_value( 'arbie' ) or false
      o.against_value( 'foobi' ) and false
    end

    def __build_subject_curry

     _normalization_class.with(
        :begin, 'barbie',
        :end, 'foobie',
      )
    end

    def _normalization_class
      _subject_module.const_get :Normalization, false
    end

    def _subject_module
      Home_::Range
    end
  end
end
