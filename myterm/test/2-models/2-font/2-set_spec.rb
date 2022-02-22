require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - font - set" do

    TS_[ self ]
    use :my_API

    same_dir = '005-fake-fonts-dir'

    context "if you try to set the font while no adapter is selected" do

      call_by do
        call :background_font, :path, 'xx'
      end

      it "fails" do
        fails
      end

      it "emits" do
        expect( last_emission ).to be_emission_ending_with :no_such_association
      end
    end

    context "try to set a font that is not found" do

      fake_fonts_dir same_dir

      call_by do
        this = 'font-geta'
        call :adapter, COMMON_ADAPTER_CONST_, :background_font, :path, this
      end

      it "fails" do
        fails
      end

      it "explains skipped font files" do

        _be_this = be_emission :info, :expression, :skipped do |y|

          # (perhaps too detailed - probably fine to delete this block)

          _s = y.fetch 0
          term = '"(?:\.[a-zA-Z0-9]+|)"=>[0-9]+'
          _rx = /\A\(skipped: \{#{ term }(?:, #{ term })*\}\)\z/

          expect( _s ).to match _rx
        end

        expect( second_emission ).to _be_this  # EEW skip first emission (`set_leaf_component`)
      end

      shared_subject :_msg_a do

        _em = last_emission
        _ev = _em.cached_event_value
        _ev.express_into_under [], expression_agent_for_want_emission
      end

      it "says that your font wasn't recognized (NOTE contextualiztion removed)" do
        expect( _msg_a.fetch( 0 ) ).to eql 'unrecognized font path "font-geta"'
      end

      it "offers around 3 levenshtein-based suggestions" do

        # #lends-coverage-to [#hu-008.2]

        # #todo the below note is old now after #history-B.1; we're gonna
        # leave it as-is because for now we don't have time to figure out
        # how to trigger the desired behavior specifially.

        # NOTE this test anchors this whole test suite to the development
        # machine. when you make fixtures make them so that the [#ba-065.2]
        # algorithm is demonstrated; i.e. have the below two fonts and
        # a few others that are "far away" from them, to demonstrate that
        # the others are cut out of the final "winners" list.

        msg = _msg_a.fetch( -1 )
        msg == 'did you mean "font-beta", "font-delta" or "font-gamma"?' || fail
      end
    end

    context "set the font using a good name" do

      fake_fonts_dir same_dir

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_,
          :background_font, :path, 'font-delta'
      end

      it "because succeeds, results in qk about the path" do

        _qk = root_ACS_result
        expect( _qk.value ).to match %r(\bfont-delta\.ttf\z)
      end

      it "event sounds natural (but is not yet contextualized)" do

        _be_this = be_emission_ending_with :set_leaf_component do |ev|

          _s = black_and_white ev

          expect( _s ).to match %r(\Aset path to "/)
        end

        expect( last_emission ).to _be_this
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
