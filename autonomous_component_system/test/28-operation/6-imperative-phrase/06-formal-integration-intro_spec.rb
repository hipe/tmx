require_relative '../../test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] operation - formal integration" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event
    use :expect_root_ACS

    context "2 deep" do

      call_by_ do
        _ = event_log.handle_event_selectively
        shoe = _shoe_model.new_cold_root_ACS_for_expect_root_ACS
        @result = shoe.edit :set, :lace, :color, "red", & _
        @root_ACS = shoe ; nil
      end

      it "the result was whatever we said it was" do
        root_ACS_result.should eql :_yergen_
      end

      it "the 'entitesque' component was attached to the compound component" do
        root_ACS.lace or fail
      end

      it "the primitive property was written to the entity" do
        root_ACS.lace.color.string.should eql "red"
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
        root_ACS_result.should eql :_yergen_
      end

      it "sets BOTH values" do
        shoe = root_ACS
        shoe.size.should eql 11
        shoe.special.should eql 'w'
      end

      it "no events" do
        expect_no_emissions
      end
    end

    it "missing multiple required args - raises argument error" do

      _s = "'set-color-of-upper' was missing required parameters #{
        }'red', 'green' and 'blue'"

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
      _shoe_model.new_cold_root_ACS_for_expect_root_ACS
    end

    def expression_agent_for_expect_event
      clean_expag_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_42_Shoe ]
    end

    alias_method :_shoe_model, :subject_root_ACS_class
  end
end
