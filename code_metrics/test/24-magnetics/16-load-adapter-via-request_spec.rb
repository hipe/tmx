require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - load adapter via request" do

    TS_[ self ]
    use :memoizer_methods
    use :treemap_node

    it "loads" do
      _subject
    end

    context "(minimal normal)" do

      same = Lazy_.call do
        Home_.dir_path
      end

      given_request do |o|
        o.head_path = same[]
        o.head_const = 'Skylab::CodeMetrics'
      end

      given_paths_for_load_tree do |y|
        head = ::File.join same[], 'magnetics'
        o = -> tail do
          ::File.join head, tail
        end
        y << o[ 'ascii-matrix-via-shapes-layers.rb' ]
        y << o[ 'shapes-layers-via-mondrian-tree.rb' ]
      end

      it "load adapter builds" do
        _load_adapter || fail
      end

      it "loads files of interest" do
        _la = _load_adapter
        _ok = _la.load_files_of_interest
        _ok || fail
      end

      shared_subject :_load_adapter do
        _req = operation_request_
        _lt = load_tree_
        _subject[ _lt, _req, & event_listener_ ]
      end
    end

    def event_listener_
      NOTHING_
    end

    def _subject
      Home_::Magnetics_::LoadAdapter_via_Request
    end
  end
end
