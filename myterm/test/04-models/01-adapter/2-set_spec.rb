require_relative '../../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] models - adapter - set" do

    TS_[ self ]
    use :my_API

    context "set with a bad name - expresses good name(s)" do

      call_by do
        call :adapter, 'whonani'
      end

      it "fails" do
        fails
      end

      it "emits (levenschtein)" do

        _be_this = be_emission :error, :extra_properties do |ev|

          s_a = black_and_white_lines ev
          s_a.first.should eql 'unrecognized adapter name "whonani"'
          s_a.last.should match %r(\Adid you mean .*"imagemagick"\?\z)
        end

        only_emission.should _be_this
      end
    end

    context "successful initial set" do

      call_by do
        call_plus_ACS :adapter, "imagemag"
      end

      it "result is the qk of the newly created adapter" do

        qk = root_ACS_result
        qk.association.name_symbol.should eql :adapter
        ada = qk.value_x
        ada.adapter_name_const.should eql COMMON_ADAPTER_CONST_
      end

      it "emits" do

        _be_this = be_emission :info, :set_leaf_component do |ev|
          _s = black_and_white ev
          _s.should eql "set adapter to 'imagemagick'"
        end

        only_emission.should _be_this
      end

      it "the ACS reflects this change" do

        _appearance = root_ACS
        _ada = _appearance.instance_variable_get( :@adapter )
        _ada.adapter_name_const or fail
      end
    end

    context "set adapter and then list adapters" do

      call_by do
        call :adapter, :imagemagick, :adapters, :list
      end

      it "the selected adapter knows it's selected" do

        st = root_ACS_result
        selected = []
        begin
          ada = st.gets
          ada or break
          if ada.instance_variable_get :@_is_selected  # ick/meh
            selected.push ada
          end
          redo
        end while nil

        _bruh = selected.fetch 0
        1 == selected.length or fail
        _bruh.adapter_name_const.should eql COMMON_ADAPTER_CONST_
      end
    end
  end
end
