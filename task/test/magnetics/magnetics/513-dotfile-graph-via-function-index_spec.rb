require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics-viz - magnetics - df g v g" do

    TS_[ self ]
    use :memoizer_methods
    use :mag_viz

    context "simple - A via B and C" do

      shared_subject :_graph do

        g = subject_module_::Models_::Graph.begin
        g.add_means [ 'biff-baz', 'quux-fum' ], 'foo-bar'
        g.finish
      end

      shared_subject :_dotfile_graph do
        subject_module_::Magnetics_::DotfileGraph_via_Graph.new( _graph ).execute
      end

      it "build graph" do
        _graph
      end

      it "build dotfile graph" do
        _dotfile_graph
      end

      it "here you can have a series of lines about the associations" do

        st = _dotfile_graph.to_association_stream
        one = st.gets
        two = st.gets
        st.gets and fail

        one.from_identifier_string == 'foo_bar' or fail
        one.to_identifier_string == 'biff_baz' or fail

        two.from_identifier_string == 'foo_bar' or fail
        two.to_identifier_string == 'quux_fum' or fail
      end

      it "here you can have a series of lines about the labels" do

        st = _dotfile_graph.to_node_stream

        one = st.gets
        two = st.gets
        three = st.gets

        st.gets and fail

        one.label == 'foo-bar' or fail
        two.label == 'biff-baz' or fail
        three.label == 'quux-fum' or fail

        one.identifier_string == 'foo_bar' or fail
        two.identifier_string == 'biff_baz' or fail
        three.identifier_string == 'quux_fum' or fail
      end
    end

    context "enter waypoint grouping - A via B or (C and D)" do

      shared_subject :_dotfile_graph do

        g = subject_module_::Models_::Graph.begin
        g.add_means [ 'be-ta' ], 'al-pha'
        g.add_means [ 'gam-ma', 'del-ta' ], 'al-pha'
        g = g.finish
        subject_module_::Magnetics_::DotfileGraph_via_Graph.new( g ).execute
      end

      it "the assocs that associate the group to the means" do

        @_a = _assocs
        _pair( 0 ) == %w( al_pha al_pha_0 ) or fail
        _pair( 1 ) == %w( al_pha al_pha_1 ) or fail
      end

      it "the assocs that make up each means" do

        @_a = _assocs
        _pair( -1 ) == %w( al_pha_1 del_ta ) or fail
        _pair( -2 ) == %w( al_pha_1 gam_ma ) or fail
        _pair( -3 ) == %w( al_pha_0 be_ta ) or fail
        5 == @_a.length or fail
      end

      def _pair d
        o = @_a.fetch( d )
        [ o.from_identifier_string, o.to_identifier_string ]
      end

      shared_subject :_assocs do
        _dotfile_graph.to_association_stream.to_a
      end

      it "the nodes that label the waypoint head and means head" do
        @_a = _nodes
        _label( 0 ) == %w( al_pha    al-pha ) or fail
        _label( 1 ) == %w( al_pha_0  (0)    ) or fail
        _label( 3 ) == %w( al_pha_1  (1)    ) or fail
      end

      it "the nodes that label the means requisites" do
        @_a = _nodes
        _label( 2 ) == %w( be_ta    be-ta  ) or fail
        _label( 4 ) == %w( gam_ma   gam-ma ) or fail
        _label( 5 ) == %w( del_ta   del-ta ) or fail
        6 == @_a.length or fail
      end

      def _label d
        o = @_a.fetch( d )
        [ o.identifier_string, o.label ]
      end

      shared_subject :_nodes do
        _dotfile_graph.to_node_stream.to_a
      end
    end
  end
end
