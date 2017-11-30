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

        _be_this = be_emission :error, :item_not_found do |ev|

          s_a = black_and_white_lines ev
          expect( s_a.first ).to eql 'unrecognized adapter name "whonani"'
          expect( s_a.last ).to match %r(\Adid you mean .*"imagemagick"\?\z)
        end

        expect( only_emission ).to _be_this
      end
    end

    context "successful initial set" do

      call_by do
        call :adapter, "imagemag"
      end

      it "result is the qk of the newly created adapter" do

        qk = root_ACS_result
        expect( qk.association.name_symbol ).to eql :adapter
        ada = qk.value
        expect( ada.adapter_name_const ).to eql COMMON_ADAPTER_CONST_
      end

      it "emits" do

        _be_this = be_emission :info, :set_leaf_component do |ev|
          _s = black_and_white ev
          expect( _s ).to eql "set adapter to 'imagemagick'"
        end

        expect( only_emission ).to _be_this
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
        expect( _bruh.adapter_name_const ).to eql COMMON_ADAPTER_CONST_
      end
    end
  end
end
