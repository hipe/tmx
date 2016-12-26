require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - node for treemap via [..] - paginate" do

    TS_[ self ]
    use :memoizer_methods
    use :treemap_node

    context "case paginate zero" do

      given_request do |o|
        o.head_const = 'Sealab::KerMerm::Mergs_'
        o.do_paginate = true
      end

      it "builds" do
        _custom_tuple || fail
      end

      it "2 items" do
        _custom_tuple.length == 2 || fail
      end

      it "each item's label is the full filename" do
        a = _custom_tuple
        a.fetch( 0 ).label_string == '/x/y/one.kd' || fail
        a.fetch( 1 ).label_string == '/x/y/two.kd' || fail
      end

      it "number of leaf nodes check out" do
        a = _custom_tuple
        number_of_leaf_nodes_of_( a[0] ) == 8 || fail
        number_of_leaf_nodes_of_( a[1] ) == 1
      end

      shared_subject :_custom_tuple do

        _path = ::File.join(
          TS_.dir_path, 'fixture-recordings', 'recording-01-woof.list' )

        st = build_treemap_node_via_recording_file_ _path
        if st
          st.to_a.freeze
        end
      end
    end

    def event_listener_
      NOTHING_
    end

    # ==

    # ==
  end
end
