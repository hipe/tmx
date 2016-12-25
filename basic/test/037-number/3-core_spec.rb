require_relative '../test-support'

module Skylab::Basic::TestSupport

  # <-

describe "[ba] number en (and stowed-away essentials too)" do

  it "(number) `of_digits_in_positive_integer`" do

    # -
      p = Home_::Number.method :of_digits_in_positive_integer

      p[ 0 ] == 1 || fail
      p[ 9 ] == 1 || fail
      p[ 12 ] == 2 || fail
      p[ 200 ] == 3 || fail
    # -
  end

  context "(number) `of_digits_before_and_after_decimal_in_positive_float` DANGER HERE" do

    it "quintessential normal minimal" do

      d, d_ = _against 3.14
      d == 1 || fail
      d_ == 2 || fail
    end

    it "dangertown - use a sanity max" do

      d, d_ = _against 2.0/3, 5
      d == 1 || fail
      d_ == 5 || fail
    end

    it "edge case: something point zero - it counts the zero as a place" do

      d, d_ = _against 12.0
      d == 2 || fail
      d_ == 1 || fail
    end

    it "same for left of the decimal point - zero counts as a place" do

      d, d_ = _against 0.3056
      d == 1 || fail
      d_ == 4 || fail
    end

    it "integeration - 0.0" do

      d, d_ = _against 0.0
      d == 1 || fail
      d_ == 1 || fail
    end

    it "(FIXED - edge case that made us use round instead of arithmetic)" do

      d, d_ = _against 1.11, 5
      d == 1 || fail
      d_ == 2 || fail
    end

    def _against f, sanity=nil
      Home_::Number.of_digits_before_and_after_decimal_in_positive_float f, sanity
    end
  end

  -> do

    m = :number
    d = 42388
    s = "forty two thousand three hundred eighty eight"

    it "via #{ m }, #{ s } becomes #{ d }" do
      _common s, d, m
    end
  end.call

  -> do

    m = :num2ord
    d = 42388
    s = "forty two thousand three hundred eighty eighth"

    it "via #{ m }, #{ s } becomes #{ d }" do
      _common s, d, m
    end
  end.call

  def _common s, d, m

    Home_::Number::EN.send( m, d ).should eql s
  end
end
# ->
end
# #tombstone - is rounding the solution to the floating point error?
