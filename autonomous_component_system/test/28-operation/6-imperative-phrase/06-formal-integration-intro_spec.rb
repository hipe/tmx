require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] operation" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :operation_imperative_phrase

    def my_model_
      shoe_model_
    end

    context "2 deep" do

      call_by_ do

        _ = event_log.handle_event_selectively
        shoe = shoe_model_.new_
        @result_ = shoe.edit :set, :lace, :color, "red", & _
        @root_ = shoe ; nil
      end

      it "the result was whatever we said it was" do
        result_.should eql :_yergen_
      end

      it "the 'entitesque' component was attached to the compound component" do
        root_ACS_.lace or fail
      end

      it "the primitive property was written to the entity" do
        root_ACS_.lace.color.string.should eql "red"
      end

      it "we see the event that was emitted from inside the operation" do

        first_emission.should( be_emission( :info, :expression, :hi ) do |a|
          a.should eql [ 'hi ** there **' ]
        end )
      end

      it "sexy emission is produced automatically (FOR NOW)" do
        last_emission.should( be_emission( :info, :component_added ) do |ev|
          black_and_white( ev ).should eql "set lace color to \"red\""
        end )
      end
    end

    context "op on level 0 ; named arguments" do

      call_by_ do
        call_ :set_size, :size, 11, :special, 'w'
      end

      it "result" do
        result_.should eql :_yergen_
      end

      it "sets BOTH values" do
        shoe = root_ACS_
        shoe.size.should eql 11
        shoe.special.should eql 'w'
      end

      it "no events" do
        emissions_count.should be_zero
      end
    end

    it "missing multiple required args - raises argument error" do

      _s = "missing required argument(s) (`red`, `green`, `blue`) #{
        }for `set_color_of_upper`"

      shoe = _new_shoe

      begin
        shoe.edit :set_color_of_upper, :alpha, :no_alpha, :blink, :yes_blink
      rescue ::ArgumentError => e
      end

      e.message.should eql _s
    end

    it "pass all requireds and one optional USES FORMAL DEFAULT" do

      shoe = _new_shoe

      _x = shoe.edit :set_color_of_upper,
        :red, :R, :green, :G, :blue, :B, :blink, :yes_blink

      _x.should eql [ :R, :G, :B, :yes_alpha, :yes_blink ]
    end

    def _new_shoe
      shoe_model_.new_
    end

    def expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end
end
