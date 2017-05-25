require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - node prototypes" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API
    use :models_node

# (1/N)

    context "can add a node to zero nodes" do

      it "what resulted from the touch operation is a guy that unparses" do  # -16/N

        _actual = _node_added_unparsed
        _actual == "cyan [label=cyan]" || fail
      end

      it "labels and symbols in the whole doc" do  # -15/N
        s_a, sym_a = _tuple[1]
        sym_a == %i( cyan ) || fail
        s_a == %w( cyan ) || fail
      end

      it "content (partial) looks OK" do
        _graph_sexp = _tuple.last
        unparsed = _graph_sexp.unparse
        unparsed[ -24 .. -1 ].should eql "*/\n\ncyan [label=cyan]\n}\n"
      end

      shared_subject :_tuple do
        with_operator_branch_for_nodes_ do
          a = []
          _ent = touch_node_via_label "cyan"
          a.push _ent
          a.push to_two_arrays__labels_and_symbols_
          a.push graph_sexp_
        end
      end

      def digraph_file_path_
        _FILE_A
      end
    end

# (2/N)
    context "having quotes in labels - that are unescaped unparses AND stringifies correctly" do

          str = %<it's a quote: ">

      it "the label looks good" do  # -14/N
        _one = _tuple.first
        _label = _one.get_node_label_
        _label == str || fail
      end

      it "the element unparsed is probably OK in the document" do  # -13/N
        _doc = _tuple.last
        _big_s = _doc.unparse
        _big_s.include? '[label="it\'s a quote: \""]' or fail
      end

      shared_subject :_tuple do

        with_operator_branch_for_nodes_ do
          a = []
          _ent = touch_node_via_label str
          a.push _ent
          a.push graph_sexp_
        end
      end

      def digraph_file_path_
        _FILE_A
      end
    end

# (3/N)
    context "can add a node to a collection of one node" do

      it "the new node unparsed looks good" do  # -12/N
        _actual = _tuple.first.node_stmt.unparse
        _actual == "cyan [label=cyan]" || fail
      end

      it "all the labels and all the node ID's in the document are OK" do
        s_a, sym_a = _tuple[1]
        s_a == %w( blue cyan ) || fail
        sym_a == %i( blue cyan ) || fail
      end

      it "the last three lines should look like this" do  # -11/N

        _actual = _THIS_MANY_LAST_N_LINES 3
        expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << "blue [label=blue]"
          y << "cyan [label=cyan]"
          y << "}"
        end
      end

      shared_subject :_tuple do

        with_operator_branch_for_nodes_ do
          a = []
          _ent = touch_node_via_label "cyan"
          a.push _ent
          a.push to_two_arrays__labels_and_symbols_
          a.push graph_sexp_
        end
      end

      def digraph_file_path_
        _FILE_B
      end
    end

# (4/N)
    context "can add a node to a collection of node one node" do

      it "added node" do
        _node_added_unparsed == "cyan [label=cyan]" || fail
      end

      it "labels and node ID's" do  # -10/N
        s_a, sym_a = _tuple[1]
        s_a == %w( cyan red ) || fail
        sym_a == %i( cyan red ) || fail
      end

      it "last 6 lines.." do  # -9/N
        _actual = _THIS_MANY_LAST_N_LINES 6
        expect_these_lines_in_array_with_trailing_newlines_ _actual do |y|
          y << '*/'
          y << ""
          y << "cyan [label=cyan]"
          y << "red [label=red]"
          y << ""  # we made an extra one on purpose
          y << '}'
        end
      end

      shared_subject :_tuple do

        with_operator_branch_for_nodes_ do
          a = []
          a.push touch_node_via_label 'cyan'
          a.push to_two_arrays__labels_and_symbols_
          a.push graph_sexp_
        end
      end

      def digraph_file_path_
        _FILE_C
      end
    end

    # -- add nodes "alphabetically" but do not rearrange existing

# (5/N)

    context "when first one comes after new one, new one goes first" do

      it "correct constuency and order" do

        _tuple.first == %i( beta gamma alpha yeti ) || fail
      end

      shared_subject :_tuple do

        with_operator_branch_for_nodes_ do
          a = []
          touch_node_via_label "beta"
          a.push to_one_array__symbols_
          a
        end
      end

      def digraph_file_path_
        _FILE_D
      end
    end

# (6/N)

    context "(inside)" do

      it "correct constuency and order" do

        _tuple.first == %i( gamma alpha ham yeti ) || fail
      end

      shared_subject :_tuple do
        with_operator_branch_for_nodes_ do
          a = []
          touch_node_via_label "ham"
          a.push to_one_array__symbols_
          a
        end
      end

      def digraph_file_path_
        _FILE_D
      end
    end

# (7/N)

    context "(last)" do

      it "correct constuency and order" do

        _tuple.first == %i( gamma alpha yeti zap ) || fail
      end

      shared_subject :_tuple do
        with_operator_branch_for_nodes_ do
          a = []
          touch_node_via_label "zap"
          a.push to_one_array__symbols_
          a
        end
      end

      def digraph_file_path_
        _FILE_D
      end
    end

# (8/N)

    context "will not redundantly add a new node if one with same label exists" do

      it "the existing entity and the touched entity have the same document element" do

        exi, tou = _existing_and_touched_node
        ns = exi.node_stmt
        ns || fail
        ns.object_id == tou.node_stmt.object_id || fail
      end

      it "the existing entity and the touched entity are not the same instance (this isn't datamapper)" do

        exi, tou = _existing_and_touched_node
        exi && tou or fail
        exi.object_id == tou.object_id && fail
      end

      it "the emission explains it all" do
        _actual = black_and_white _tuple[1]
        _actual == 'found existing node "yeti"' || fail
      end

      def _existing_and_touched_node
        a = _tuple
        [ a.first, a.last ]
      end

      shared_subject :_tuple do

        with_operator_branch_for_nodes_ do

          a = []

          _existing_ent = @OB_FOR_NODES.lookup_softly_via_node_ID__ :yeti
          a.push _existing_ent

          call_by do |p|
            touch_node_via_label "yeti", & p
          end

          expect :info, :found_existing_node do |ev|
            a.push ev
          end

          a.push execute
        end
      end

      def digraph_file_path_
        _FILE_D
      end
    end

    # -- expectations

    def _node_added_unparsed
      _ent = _tuple.first
      _ns = _ent.node_stmt
      _ns.unparse
    end

    def _THIS_MANY_LAST_N_LINES d

      _big_s = _tuple.last.unparse

      # (you could do [#ba-024] string scanner on the big string and then
      # use a [#ba-027] rotating buffer to get the last N lines but we find
      # it *very* likely that that would be significantly lest performant
      # than what we do below (#open [#bm-016] (in [sl])))

      lines = _big_s.split %r(^)  # LINE_SPLITTING_RX_

      3 > lines.length && fail

      lines[ -d .. -1 ]
    end

    # -- setup

    def _FILE_D
      fixture_file_ "simple-prototype-and-graph-with/three.dot"
    end

    def _FILE_C
      fixture_file_ "simple-prototype-and-graph-with/one-that-comes-after.dot"
    end

    def _FILE_B
      fixture_file_ "simple-prototype-and-graph-with/one-that-comes-before.dot"
    end

    def _FILE_A
      fixture_file_ "simple-prototype-and-graph-with/zero.dot"
    end

    # ==
    # ==

  end
end
# #history-A.1: full rewrite for post [br]
