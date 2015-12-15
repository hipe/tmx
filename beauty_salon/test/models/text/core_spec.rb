require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] models - text (wrap)" do

    extend TS_
    use :expect_event

    it "number not number" do

      _with :num_chars_wide, 'zango'
      expect_failed_by_ :uninterpretable_under_number_set
    end

    it "number too low" do

      _with :num_chars_wide, -1
      expect_failed_by_ :number_too_small
    end

    it "some money" do

      _path = _universal_fixture( :three_lines )
      _with(
        :informational_downstream, ( _a = [] ),
        :output_bytestream, ( _a_ = [] ),
        :upstream, ::File.open( _path ),
        :num_chars_wide, 22,
      )

      _a.length.should be_zero

      _a_.should eql([
        "it's time for\n",
        "WAZOOZLE, see\n",
        "fazzoozle my noozle\n",
        "when i say \"wazoozle\"\n",
        "i mean WaZOOzle!\n",
      ])

      expect_succeeded
    end

    def _universal_fixture sym
      TestSupport_::Fixtures.file( sym )
    end

    def _with * x_a

      h = {
        upstream: :_x_,
        num_chars_wide: 1,
        informational_downstream: :_xx_,
        output_bytestream: :_xxx_,
      }

      x_a.each_slice 2 do | k, x |
        h[ k ] = x
      end

      call_API( :wrap,
        :upstream, h.fetch( :upstream ),
        :num_chars_wide, h.fetch( :num_chars_wide ),
        :informational_downstream, h.fetch( :informational_downstream ),
        :output_bytestream, h.fetch( :output_bytestream ),
      )
    end
  end
end
