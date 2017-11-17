require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] intent streamer via node reference streamer" do

    # (the subsequent test tests `include_if` so we don't)

    TS_[ self ]
    use :memoizer_methods
    # NOTE - see #expect-no-events below
    use :want_root_ACS

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

      _node_sr = Home_::Magnetics::NodeReferenceStreamer_via_FeatureBranch.via_ACS _acs

      o = Home_::Magnetics_::IntentStreamer_via_NodeReferenceStreamer.via_streamer__ _node_sr

      _x = _cust_x
      o = _x[ o ]
      st = o.to_node_stream

      a = []
      begin
        ref = st.gets  # [#035]
        ref || break
        a.push ref.name_symbol
        redo
      end while above
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
