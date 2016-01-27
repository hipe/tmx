require_relative 'test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] for serialization" do

    # (intent)

    TS_[ self ]
    use :memoizer_methods
    # NOTE - see #expect-no-events below
    use :expect_root_ACS

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
        _x = _something
        _x.should eql %i( red_floof red_flingle )
      end
    end

    def _something

      _acs = _ACS
      _x = _cust_x
      st = Home_::For_Serialization::To_stream[ _x, _acs ]
      a = []
      begin
        x = st.gets
        x or break
        a.push x.name_symbol
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
