require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] magnetics - persistable primitive name value pair stream via etc" do

    # (intent)

    TS_[ self ]
    use :memoizer_methods
    # NOTE - see #expect-no-events below
    use :want_root_ACS

    shared_subject :_ACS do
      build_root_ACS
    end

    context "whitelist-based (include if red)" do

      def _cust_x

        -> o do
          rx = /\Ared_/
          o.include_if = -> no do
            rx =~ no.name_symbol
          end
          o
        end
      end

      it "ok." do
        _x = ___build_name_symbol_array
        expect( _x ).to eql %i( red_floof red_flingle )
      end
    end

    def ___build_name_symbol_array

      _acs = _ACS
      _x = _cust_x

      st = Home_::Magnetics_::
        PersistablePrimitiveNameValuePairStream_via_Choices_and_FeatureBranch.
      via_customization_and_ACS _x, _acs

      a = []
      begin
        qk = st.gets
        qk or break
        a.push qk.name_symbol
        redo
      end while nil
      a
    end

    def event_log  # #expect-no-events
      NIL_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_24_Multi_Intent ]
    end
  end
end
