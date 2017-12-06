require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - depth intro" do

    TS_[ self ]
    use :my_API

    context "call top node with something strange:" do

      call_by do
        call :something  # #test-02
      end

      it "fails" do
        fails
      end

      it "message tail enumerates the available items (with glyphs)" do

        _be_this = be_emission_ending_with :no_such_association do |ev|

          _ = black_and_white ev
          expect( _ ).to look_like_did_you_mean_for_ %w( subject verb_phrase )
        end

        expect( only_emission ).to _be_this
      end
    end

    context "(from root) land on a compound when it is NOT set" do

      call_by do
        call :verb_phrase  # #test-08
      end

      it "results in a qk talking bout unknown" do

        qk = root_ACS_result
        qk.is_known_known and fail
        expect( qk.name_symbol ).to eql :verb_phrase
      end

      def event_log
        NIL_
      end
    end

    context "(from root) land on a compound when it IS set" do

      call_by do

        @root_ACS = build_root_ACS
        @root_ACS.set_verb_phrase_for_want_root_ACS :_xXx_

        call :verb_phrase  # #test-09
      end

      it "results in a qk talking bout unknown" do

        qk = root_ACS_result
        qk.is_known_known or fail
        expect( qk.name_symbol ).to eql :verb_phrase
        expect( qk.value ).to eql :_xXx_
      end

      def event_log
        NIL_
      end
    end

    context "deep time" do

      call_by do
        call( :subject, 'you',
          :verb_phrase,
            :object, 'cocoa',
            :verb, 'like',  # [#test-11-ish &] #test-50-11-ish
        )
      end

      it "result is the last componet that was set - a primitivesque" do
        qk = root_ACS_result
        expect( qk.value ).to eql 'like'
        expect( qk.association.name_symbol ).to eql :verb
      end

      it "(emits each time a leaf component was set)" do

        be_this_emission = be_emission :info, :set_leaf_component
        st = Home_::Stream_[ root_ACS_state.emission_array ]

        3.times do
          _ = st.gets
          expect( _ ).to be_this_emission
        end
        st.gets and fail
      end
    end

    def subject_root_ACS_class
      Remote_fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
