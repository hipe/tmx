require_relative '../test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] magnetics - mondrian tree via [..] - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :common_magnets_and_models

    context "two component, flat dataset - check translating scaling" do

      it "node tree builds" do
        _node_tree || fail
      end

      it "quantity tree build" do
        _quantity_tree || fail
      end

      it "mondrian tree builds" do
        _mondrian_tree || fail
      end

      it "associated node is a branch with two sub-nodes" do
        an = _mondrian_tree.associated_node
        an.is_branch || fail
        an.associated_nodes.length == 2 || fail
      end

      it "each of those subnodes has translated/scaled rects that look right" do

        mt = _mondrian_tree
        an = mt.associated_node

        ts = mt.scaler_translator

        world_rects = []
        labels = []

        an.associated_nodes.each do |an_|

          labels.push an_.tuple.label_string

          an_.is_branch && fail

          _hi = an_.normal_rectangle.scale_and_translate_for ts

          world_rects.push _hi
        end

        d = 0
        labels.fetch( d ) == "moonlight hours" || fail
        re = world_rects.fetch d
        re.x == 20 || fail
        re.y == 10 || fail
        re.width == 500 || fail
        re.height == 123 || fail

        d = 1
        labels.fetch( d ) == "sunlight hours" || fail
        re = world_rects.fetch d
        re.x == 520 || fail
        re.y == 10 || fail
        re.width == 300 || fail
        re.height == 123 || fail
      end

      shared_subject :_mondrian_tree do

        _ = _quantity_tree

        mondrian_tree_via_quantity_tree _ do |o|
          o.target_rectangle = 20, 10, 800, 123
        end
      end

      shared_subject :_quantity_tree do
        _ = _node_tree
        quantity_tree_via_node_tree _
      end

      shared_subject :_node_tree do

        build_node_tree_by do |o|
          o.add_item 'sunlight hours', 9
          o.add_item 'moonlight hours', 15
        end
      end
    end

    # (what was once the next test here moved to [#cm-016] because
    #  it was too much eyeblood not to test it visuo-automatedly)

    context "introduce depth (integrate (covered) deep quantity tree)" do

      it "mondrian tree builds" do
        _mondrian_tree || fail
      end

      it "those branch nodes in the data MUST correspond to visual branch nodes.." do

        an = _mondrian_tree.associated_node

        an.is_branch || fail

        an.associated_nodes.length == 3 || fail

        _hi = an.associated_nodes.map do |an_|
          an_.is_branch
        end

        _hi == [ true, true, false ]
      end

      # (see you in the [#cm-016] ascii tests..)

      shared_subject :_mondrian_tree do

        _qt = groceries_A_quantity_tree

        mondrian_tree_via_quantity_tree _qt do |o|
          o.target_rectangle = 20, 10, 800, 123
        end
      end
    end
  end
end
