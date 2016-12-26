require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - node for treemap via [..] - omni " do

    TS_[ self ]
    use :memoizer_methods
    use :treemap_node

    context "case omni zero - first ever use of model" do

      given_request do |o|
        o.head_const = 'Sealab::KerMerm::Mergs_'
      end

      it "builds" do
        treemap_node_ || fail
      end

      it "root node label talkin bout 2 files" do
        treemap_node_.label_string == "(2 files)" || fail
      end

      it "N leaf nodes" do
        _stats.number_of_leaf_nodes == 9 || fail
      end

      it "q max depth" do
        _stats.max_depth == 3 || fail
      end

      shared_subject :_stats do
        build_treemap_node_statistics_
      end

      shared_subject :treemap_node_ do
        _path = ::File.join(
          TS_.dir_path, 'fixture-recordings', 'recording-01-woof.list' )
        build_treemap_node_via_recording_file_ _path
      end
    end

    def event_listener_
      NOTHING_
    end

    # ==

    # ==
  end
end
