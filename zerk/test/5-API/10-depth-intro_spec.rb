require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] API - depth intro", wip: true do

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

        only_emission.should ( be_emission :error, :uninterpretable_token do | ev |

          _ = black_and_white ev

          _.should match %r(, expecting \{ subject \| verb_phrase \}\z)
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

      it "wins" do
        self._CHANGED
        expect_result_for_success_
      end

      it "evo" do

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
      _require_model
      Two_Sentence
    end

    def _build_verb_phrase
      _require_model
      Two_Verb_Phrase.new
    end

    def _require_model
      Remote_fixture_top_ACS_class[ :Class_41_Sentence ]
    end
  end
end
