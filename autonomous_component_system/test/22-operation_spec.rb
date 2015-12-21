require_relative 'test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] operation" do

    extend TS_
    use :operation
    use :future_expect

    it "goes 2 deep; autovivifies; takes 1 arg" do

      future_expect_only :info, :expression, :hi do | a |
        a.should eql [ 'hi ** there **' ]
      end

      shoe = _new_shoe

      shoe.lace.should be_nil

      _ok = shoe.edit :set, :lace, :color, "red", & fut_p

      _ok.should eql :_yergen_

      future_is_now

      shoe.lace.color.string.should eql "red"
    end

    it "op on level 0 ; named arguments" do

      shoe = _new_shoe

      shoe.edit :set_size, :size, 11, :special, 'w'

      shoe.size.should eql 11
      shoe.special.should eql 'w'
    end

    it "missing multiple required args - raises argument error" do

      shoe = _new_shoe

      begin
        shoe.edit :set_color_of_upper, :alpha, :no_alpha, :blink, :yes_blink
      rescue ::ArgumentError => e
      end

      e.message.should eql "call to `set_color_of_upper` #{
        }missing required argument(s): (`green`, `red`, `blue`)"
    end

    it "pass all requireds and one optional USES PLATFORM DEFAULT" do

      shoe = _new_shoe

      _x = shoe.edit :set_color_of_upper,
        :red, :R, :green, :G, :blue, :B, :blink, :yes_blink

      _x.should eql [ :R, :G, :B, :yes_alpha, :yes_blink ]
    end

    it "do similar, but note you cannot hop optionals!" do

      shoe = _new_shoe

      begin

        shoe.edit :set_color_of_upper,
          :red, :R, :green, :G, :blue, :B, :alpha, :no_alpha
      rescue ::ArgumentError => e
      end

      e.message.should match (
        /\Acannot have explicit value for `alpha` when no value is #{
         }passed for `blink` / )
    end

    def _new_shoe
      shoe_model_.new_
    end
  end
end
