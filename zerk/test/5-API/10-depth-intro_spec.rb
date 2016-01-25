require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - depth intro" do

    TS_[ self ]
    use :API

    context "call top node with something strange:" do

      call_by do
        call :something
      end

      it "fails" do
        fails
      end

      it "message tail enumerates the available items (with glyphs)" do

        only_emission.should ( be_emission_ending_with :no_such_association do |ev|

          _ = black_and_white ev
          _.should look_like_did_you_mean_for_ %w( subject verb_phrase )
        end )
      end
    end

    context "deep time" do

      call_by do
        call( :subject, 'you',
          :verb_phrase,
            :object, 'cocoa',
            :verb, 'like',
        )
      end

      it "result is the last componet that was set - a primitivesque" do
        qk = root_ACS_result
        qk.value_x.should eql 'like'
        qk.association.name_symbol.should eql :verb
      end

      it "(emits each time a leaf component was set)" do

        be_this_emission = be_emission :info, :set_leaf_component
        st = Callback_::Stream.via_nonsparse_array root_ACS_state.emission_array

        3.times do
          _ = st.gets
          _.should be_this_emission
        end
        st.gets and fail
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
