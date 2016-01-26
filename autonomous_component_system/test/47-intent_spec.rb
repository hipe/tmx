require_relative 'test-support'

module Skylab::Autonomous_Component_System::TestSupport

  describe "[ac] intent" do

    # (the subsequent test tests `include_if` so we don't)

    TS_[ self ]
    use :memoizer_methods
    use :expect_root_ACS

    shared_subject :_ACS do
      build_root_ACS
    end

    context "exclude by name" do

      def _cust_x

        -> o do
          o.exclude :blue_flingle
          o
        end
      end

      it "ok." do
        a = _something
        a.length > 1 or fail
        a.first.respond_to?( :id2name ) or fail
        a.include? :red_floof or fail
        a.include? :blue_flingle and fail
      end
    end

    def _something

      _acs = _ACS

      _node_st = Home_::Reflection::To_node_stream_via_inference[ _acs ]

      o = Home_::Intent::Streamer.new _node_st
      _x = _cust_x
      o = _x[ o ]
      st = o.to_node_stream

      a = []
      begin
        no = st.gets
        no or break
        a.push no.name_symbol
        redo
      end while nil
      a
    end

    def event_log
      NIL_
    end

    def subject_root_ACS_class
      Fixture_top_ACS_class[ :Class_24_Multi_Intent ]
    end
  end
end
