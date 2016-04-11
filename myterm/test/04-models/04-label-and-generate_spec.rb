require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - label & [near] generate" do

    TS_[ self ]
    use :my_API

    context "set a bad label" do

      call_by do
        call :adapter, COMMON_ADAPTER_CONST_,
          :label, EMPTY_S_
      end

      it "fails" do
        fails
      end

      it "emits (NO CONTEXT)" do

        _be_this = be_emission_ending_with :is_not, :nonblank do |y|
          y.should eql [ "cannot be blank" ]
        end

        last_emission.should _be_this
      end
    end

    context "`imagemagick_command`" do

      call_by do
        call_plus_ACS :adapter, COMMON_ADAPTER_CONST_,
          :label, 'welff',
          :background_font, :path, '/talisker/I_AM_a_font.dfont',
            # (the inceptionpoint was here for needing to pop frames)
          :imagemagick_command
      end

      def build_root_ACS_
        _this_ACS
      end

      it "resultant command structure has the command words as tokens" do

        _s_a = root_ACS_result.string_array

        _s_a.fetch( -2 ).should eql 'label:welff'
      end

      it "resultant command structure will express under modality" do

        _ = root_ACS_result.express_into_under "", :_not_used_

        _.should match %r(\Aconvert .+volatile-image\.png\z)
      end
    end

    context "`OSA_script`" do

      call_by do
        call_plus_ACS :adapter, COMMON_ADAPTER_CONST_,
          :label, 'iota',
          :background_font, :path, 'wazoozle',
          :OSA_script
      end

      def build_root_ACS_
        _this_ACS
      end

      it "resultant script structure expresses under modality" do

        _ = root_ACS_result

        a = _.express_into_under [], :_not_used_

        a.first.should eql "tell application \"iTerm2\"\n"

        a.last.should match %r(return "script result:)
      end
    end

    def _this_ACS  # •cp3
      _cls = Home_::Models_::Appearance
      _k = TS_::Stubs::Kernel_01_Hi.instance
      _cls.new _k
    end
  end
end
