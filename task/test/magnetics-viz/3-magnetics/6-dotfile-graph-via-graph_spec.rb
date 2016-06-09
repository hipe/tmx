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
  end
end
