require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (public) - ASCII matrix via shapes layers - early integ" do

    # this is :[#016] a test whose scope is shared by [tr] and us.
    # originally in [tr] this began as intending to check the orientation
    # change of rectangle splitting, but was too annoying to check all those
    # vertices without doing it visually so here we are. with this same
    # justification this test is not placed to correspond to the main magnet
    # it covers.

    TS_[ self ]
    use :memoizer_methods
    Home_.lib_.treemap.test_support::Common_Magnets_And_Models[ self ]
    use :mondrian_ASCII

    context "this minimal case from [tr] - how does it render" do

      given_mondrian_tree do

        mondrian_tree_by_mondrian_choices_and_build_node_tree -> o do
          o.target_rectangle = 240, 50
        end, -> o do
          o.add_item 'sunlight hours', 9
          o.add_item 'moonlight hours', 15
        end
      end

      given_choices do |o|
        o.pixels_wide = 24
        o.pixels_high = 5
      end

      will_expect_big_string do

        # would change slightly at [#007.C] (as you can imagine). we
        # just thought of a middle-ground workaround but later for that.

        <<-HERE
          ¦+-------------++-------+¦
          ¦|             ||       |¦
          ¦|moonlight hou||sunligh|¦
          ¦|             ||       |¦
          ¦+-------------++-------+¦
        HERE
      end

      it "every byte is correct" do
        expect_every_byte_is_correct_
      end
    end

    # ==

    context "why is vertical splitting losing height?" do

      given_mondrian_tree do
        mondrian_tree_by_mondrian_choices_and_build_node_tree(
          -> o do
            o.target_rectangle = 120, 100
            o.portrait_landscape_threshold_rational = squareish_in_ASCII_
          end,
          -> o do
            o.add_item 'xbox 360', 150
            o.add_item 'ps4', 230
          end,
        )
      end

      given_choices do |o|
        o.pixels_wide = 12
        o.pixels_high = 10
      end

      will_expect_big_string do
        <<-HERE
          ¦+----------+¦
          ¦|          |¦
          ¦|   ps4    |¦
          ¦|          |¦
          ¦|          |¦
          ¦+----------+¦
          ¦+----------+¦
          ¦| xbox 360 |¦
          ¦|          |¦
          ¦+----------+¦
        HERE
      end

      it "every byte is correct" do
        expect_every_byte_is_correct_
      end
    end

    # ==

    context "this one flat dataset - check split orientation change" do

      given_mondrian_tree do
        mondrian_tree_by_mondrian_choices_and_build_node_tree(
          -> o do
            o.target_rectangle = 480, 100
            o.portrait_landscape_threshold_rational = Rational( 6 ) / Rational( 11 )
          end,
          -> o do
            o.add_item 'wii u', 290
            o.add_item 'xbox 360', 150
            o.add_item 'ps3', 170
            o.add_item 'xbox one', 250
            o.add_item 'ps4', 230
          end,
        )
      end

      given_choices do |o|
        o.pixels_wide = 48
        o.pixels_high = 10
      end

      will_expect_big_string do
        <<-HERE
          ¦+----------++------------++---------++---------+¦
          ¦|          ||            ||         ||         |¦
          ¦|          ||    ps3     ||         ||         |¦
          ¦|          ||            ||         ||         |¦
          ¦|  wii u   |+------------+|xbox one ||   ps4   |¦
          ¦|          |+------------+|         ||         |¦
          ¦|          ||            ||         ||         |¦
          ¦|          ||  xbox 360  ||         ||         |¦
          ¦|          ||            ||         ||         |¦
          ¦+----------++------------++---------++---------+¦
        HERE
      end

      it "every byte is correct" do
        expect_every_byte_is_correct_
      end
    end
    # (at writing the above dataset looked good at 2x as big)

    # ==

    # ==

    # ==
  end
end
