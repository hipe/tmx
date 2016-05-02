require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - set" do

    TS_[ self ]
    use :my_API

    # NOTE the below tests with shouts in their names are #open [#012]

    context "if you try to set the font while no adapter is selected" do

      call_by do
        call :background_font, :path, 'xx'
      end

      it "fails" do
        fails
      end

      it "emits" do
        last_emission.should be_emission_ending_with :no_such_association
      end
    end

    context "try to set a font that is not found (LIVE, FRAGILE)" do

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_, :background_font, :path, 'NOTAFONT'
      end

      it "fails" do
        fails
      end

      it "explains skipped font files (LIVE, FRAGILE)" do

        _be_this = be_emission :info, :expression, :skipped do |y|

          # (perhaps too detailed - probably fine to delete this block)

          _s = y.fetch 0
          term = '"(?:\.[a-zA-Z0-9]+|)"=>[0-9]+'
          _rx = /\A\(skipped: \{#{ term }(?:, #{ term })*\}\)\z/

          _s.should match _rx
        end

        second_emission.should _be_this  # EEW skip first emission (`set_leaf_component`)
      end

      shared_subject :_msg_a do

        _em = last_emission
        _ev = _em.cached_event_value
        _ev.express_into_under [], expression_agent_for_expect_event
      end

      it "says that your font wasn't recognized (NOTE contextualiztion removed)" do
        _msg_a.fetch( 0 ).should eql 'unrecognized font path "NOTAFONT"'
      end

      it "offers 3 levenshtein-based suggestions" do
        _msg = _msg_a.fetch( -1 )
        _ = '"[^"]+"'
        _rx = %r(\Adid you mean #{ _ }, #{ _ } or #{ _ }\?\z)
        _msg.should match _rx
      end
    end

    context "set the font using a good name (FRAGILE)" do

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_,
          :background_font, :path, 'monaco'
      end

      it "because succeeds, results in qk about the path" do

        _qk = root_ACS_result
        _qk.value_x.should match %r(\bMonaco\.dfont\z)
      end

      it "event sounds natural (but is not yet contextualized)" do

        _be_this = be_emission_ending_with :set_leaf_component do |ev|

          _s = black_and_white ev

          _s.should match %r(\Aset path to "/)
        end

        last_emission.should _be_this
      end

      it "IMPORTANT the new compound gets placed **under the adapter**" do

        _root = root_ACS
        _ada = _root.adapter
        _impl = _ada.instance_variable_get :@_impl
        _x = _impl.instance_variable_get :@background_font
        _ = _x.instance_variable_get :@path
        _ or fail
      end
    end
  end
end
# #tombstone - a few detailed tests about JSON (un)serialization
