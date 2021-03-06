require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] operation - formal integration" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event
    use :want_root_ACS

    context "2 deep" do

      call_by_ do
        _ = event_log.handle_event_selectively
        shoe = _shoe_model.new_cold_root_ACS_for_want_root_ACS
        @result = shoe.edit :set, :lace, :color, "red", & _
        @root_ACS = shoe ; nil
      end

      it "the result was whatever we said it was" do
        expect( root_ACS_result ).to eql :_yergen_
      end

      it "the 'entitesque' component was attached to the compound component" do
        root_ACS.lace or fail
      end

      it "the primitive property was written to the entity" do
        expect( root_ACS.lace.color.string ).to eql "red"
      end

      it "we see the event that was emitted from inside the operation" do

        _be_this = be_emission :info, :expression, :hi do |a|
          expect( a ).to eql [ 'hi ** there **' ]
        end

        expect( first_emission ).to _be_this
      end

      it "sexy emission is produced automatically (FOR NOW)" do

        _be_this = be_emission :info, :component_added do |ev|
          expect( black_and_white ev ).to eql 'set lace color to "red"'
        end

        expect( last_emission ).to _be_this
      end
    end

    context "op on level 0 ; named arguments" do

      call_by_ do
        call_ :set_size, :size, 11, :special, 'w'
      end

      it "result" do
        expect( root_ACS_result ).to eql :_yergen_
      end

      it "sets BOTH values" do
        shoe = root_ACS
        expect( shoe.size ).to eql 11
        expect( shoe.special ).to eql 'w'
      end

      it "no events" do
        want_no_emissions
      end
    end

    it "missing multiple required args - raises argument error" do

      _be_this_msg = match %r(\A'set-color-of-upper' #{
        }is missing required parameters #{
          }'red', 'green' and 'blue')

      shoe = _new_shoe

      begin
        shoe.edit :set_color_of_upper, :alpha, :no_alpha, :blink, :yes_blink
      rescue Home_::MissingRequiredParameters => e
      end

      expect( e.message ).to _be_this_msg
    end

    it "pass all requireds and one optional USES FORMAL DEFAULT" do

      shoe = _new_shoe

      _x = shoe.edit :set_color_of_upper,
        :red, :R, :green, :G, :blue, :B, :blink, :yes_blink

      expect( _x ).to eql [ :R, :G, :B, :yes_alpha, :yes_blink ]
    end

    def _new_shoe
      _shoe_model.new_cold_root_ACS_for_want_root_ACS
    end

    def expression_agent_for_want_emission
      expag_for_cleanliness_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_42_Shoe ]
    end

    alias_method :_shoe_model, :subject_root_ACS_class
  end
end
