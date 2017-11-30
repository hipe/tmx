require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI - horizontal meter (NOT integrated with table)" do

    TS_[ self ]
    # use :memoizer_methods

    context "(what a negative minimum does)" do

      it "x." do

        hm = _subject_module.define do |o|
          o.denominator 20
          o.background_glyph '-'
          o.target_final_width 10
          o.negative_minimum( -10 )
        end

        _act = hm % -5
        expect( _act ).to eql "++--------"

        _act = hm % 5
        expect( _act ).to eql "+++++++---"
      end
    end

    def _subject_module
      Home_::CLI::HorizontalMeter
    end
  end
end
