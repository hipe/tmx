require_relative '../test-support'

module Skylab::Treemap::TestSupport

  describe "[tr] magnetics - mondrian tree via [..] - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :common_magnets_and_models

    same_rect = 20, 10, 800, 123

    context "one component, zero-weight leaf" do

      it "mesh branch with 1 child node" do
        expect_mesh_branch_with_this_many_nodes_ 1
      end

      it "root rectangle has nonzero volume" do
        expect_nonzero_volume_ root_rectangle_
      end

      it "child rectangle has zero volume" do
        expect_zero_volume_ child_rectangle_at_offset_ 0
      end

      shared_subject :mondrian_tree_ do
        build_mondrian_tree_commonly_ same_rect
      end

      def build_node_tree_
        build_node_tree_by do |o|
          o.add_item 'lone child of zero', 0
        end
      end
    end

    context "one component, nonzero-weight leaf" do

      it "mesh branch with 1 child" do
        expect_mesh_branch_with_this_many_nodes_ 1
      end

      it "child rectangle has nonzero volume" do
        expect_nonzero_volume_ child_rectangle_at_offset_ 0
      end

      it "(for now, the lone child allocates a NEW but identical sub-rect)" do

        rect = root_rectangle_
        rect_ = child_rectangle_at_offset_ 0

        %i( x y width height ).each do |m|
          rect.send( m ) == rect_.send( m ) || fail
        end

        rect == rect_ && fail  # only because we haven't implemented the method
      end

      shared_subject :mondrian_tree_ do
        build_mondrian_tree_commonly_ same_rect
      end

      def build_node_tree_
        build_node_tree_by do |o|
          o.add_item 'lone child', 10000
        end
      end
    end

    context "two component, all positive, simpound - check translating scaling" do

      it "mondrian tree builds" do
        mondrian_tree_ || fail
      end

      it "associated node is a branch with two sub-nodes" do
        expect_mesh_branch_with_this_many_nodes_ 2
      end

      it "each of those subnodes has translated/scaled rects that look right" do

        ts = mondrian_tree_.scaler_translator

        world_rects = []
        labels = []

        child_mesh_nodes_.each do |mn|

          labels.push mn.tuple.label_string

          mn.is_branch && fail

          _hi = mn.normal_rectangle.scale_and_translate_for ts

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

      shared_subject :mondrian_tree_ do
        build_mondrian_tree_commonly_ same_rect
      end

      def build_node_tree_
        build_node_tree_by do |o|
          o.add_item 'sunlight hours', 9
          o.add_item 'moonlight hours', 15
        end
      end
    end

    half_rational = Rational( 1 ) / Rational( 2 )

    context "(regress the next test. almost everything is here.)" do

      it "despite argument order, they are in descending size order" do

        nodes = child_mesh_nodes_
        p = -> d do
          nodes.fetch( d ).tuple.label_string
        end
        p[ 0 ] == :three || fail
        p[ 1 ] == :two || fail
        p[ 2 ] == :one || fail
      end

      it "the largest of the three items occupies whole top half of frame" do

        rec = _child_rex.fetch 0
        rec.x == 0 || fail
        rec.y == 0 || fail
        rec.width == 1 || fail
        rec.height == half_rational || fail
      end

      it "the other two occupy the lower half, proportionally" do

        two_thirds = Rational( 2 ) / Rational( 3 )

        rec = _child_rex.fetch 1
        rec.x == 0 || fail
        rec.y == half_rational || fail
        rec.width == two_thirds || fail
        rec.height == half_rational || fail

        rec = _child_rex.fetch 2
        rec.x == two_thirds || fail
        rec.y == half_rational || fail
        rec.width == Rational( 1 ) / Rational( 3 ) || fail
        rec.height == half_rational || fail
      end

      shared_subject :_child_rex do
        map_child_rectangles_
      end

      shared_subject :mondrian_tree_ do
        build_mondrian_tree_commonly_ [ 0, 0, 1, 1 ]
      end

      def build_node_tree_
        build_node_tree_by do |o|
          o.add_item :one, 1
          o.add_item :three, 3
          o.add_item :two, 2
        end
      end
    end

    context "zeroes and nonzeros, simpound" do

      it "one of the weights is zero, but all the volumes add up." do

        individual_volumes = []

        zero_count = nonzero_count = 0

        child_mesh_nodes_.each do |mn|
          rect = mn.normal_rectangle
          if rect.has_zero_volume
            zero_count += 1
          else
            nonzero_count += 1
          end
          individual_volumes.push rect.width * rect.height
        end

        rect = root_rectangle_
        _full_volume = rect.width * rect.height

        zero_count == 1 || fail
        nonzero_count == 3 || fail

        _actual_total_volume = individual_volumes.reduce( & :+ )

        _actual_total_volume == 1 || fail

        # (if you change the height from `12` to e.g `14`, the actual volume
        # becomes 7/6, because it's width of 1.0 times height in width units)
      end

      shared_subject :mondrian_tree_ do
        build_mondrian_tree_commonly_ [ 5, 5, 12, 12 ]
      end

      def build_node_tree_
        build_node_tree_by do |o|
          o.add_item 'one', 1
          o.add_item 'three', 3
          o.add_item 'zero', 0
          o.add_item 'two', 2
        end
      end
    end

    # (what was once the next test here moved to [#cm-016] because
    #  it was too much eyeblood not to test it visuo-automatedly)

    context "introduce depth (integrate (covered) deep quantity tree)" do

      it "mondrian tree builds" do
        mondrian_tree_ || fail
      end

      it "those branch nodes in the data MUST correspond to visual branch nodes.." do

        expect_mesh_branch_with_this_many_nodes_ 3

        _hi = child_mesh_nodes_.map do |an_|
          an_.is_branch
        end

        _hi == [ true, true, false ] || fail
      end

      # (see you in the [#cm-016] ascii tests..)

      shared_subject :mondrian_tree_ do

        _qt = groceries_A_quantity_tree

        mondrian_tree_via_quantity_tree _qt do |o|
          o.target_rectangle = 20, 10, 800, 123
        end
      end
    end

    # -- expectation support

    def expect_mesh_branch_with_this_many_nodes_ len
      root_mesh_node_.is_branch || fail
      child_mesh_nodes_.length == len || fail
    end

    def expect_nonzero_volume_ rect
      rect.has_zero_volume && fail
    end

    def expect_zero_volume_ rect
      rect.has_zero_volume || fail
    end

    def root_rectangle_
      root_mesh_node_.normal_rectangle
    end

    def child_rectangle_at_offset_ d
      child_mesh_nodes_.fetch( d ).normal_rectangle
    end

    def map_child_rectangles_
      child_mesh_nodes_.map( & :normal_rectangle )
    end

    def child_mesh_nodes_
      root_mesh_node_.mesh_nodes
    end

    def root_mesh_node_
      mondrian_tree_.mesh_node
    end

    # -- setup support

    def build_mondrian_tree_commonly_ rect

      nt = build_node_tree_
      nt || fail

      qt = quantity_tree_via_node_tree nt
      qt || fail

      mondrian_tree_via_quantity_tree qt do |o|
        o.target_rectangle = rect
      end
    end

    # ==
  end
end
