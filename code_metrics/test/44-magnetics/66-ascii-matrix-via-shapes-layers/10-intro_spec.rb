require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (public) - ASCII matrix via shapes layers" do

    TS_[ self ]
    use :mondrian_ASCII

    # NOTE the unicode character ("¦") in the "big strings" is NOT part of
    # the expected visualization - it demarcates the beginning and ending
    # of each such line in this file. justification at [#ts-031.1].

    context "here's the smallest rect that can render (no scale)" do

      will_expect_big_string do
        <<-HERE
         ¦++¦
         ¦++¦
        HERE
      end

      given_choices do
        Home_::Models::MondrianAsciiChoices.define do |o|
          o.pixels_wide = 2
          o.pixels_high = 2
        end
      end

      given_shapes_layers do

        Home_::Models::ShapesLayers.define do |sls|

          sls.width_height 2, 2

          sls.add_layer do |o|
            o.add_rect 0, 0, 2, 2
          end
        end
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    context "smallest rect with a fill (no scale)" do

      will_expect_big_string do
        <<-HERE
         ¦       ¦
         ¦  +-+  ¦
         ¦  | |  ¦
         ¦  +-+  ¦
         ¦       ¦
        HERE
      end

      given_choices do |o|
        o.pixels_wide = 7
        o.pixels_high = 5
      end

      given_shapes_layers do |sls|

        sls.width_height 7, 5

        sls.add_layer do |o|
          o.add_rect 2, 1, 3, 3
        end
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    context "scale up" do

      will_expect_big_string do
        <<-HERE
          ¦+--------+¦
          ¦|        |¦
          ¦|        |¦
          ¦|        |¦
          ¦+--------+¦
        HERE
      end

      given_choices do |o|
        o.pixels_wide = 10
        o.pixels_high = 5
      end

      given_shapes_layers do |sls|

        sls.width_height 3, 3

        sls.add_layer do |o|
          o.add_rect 0, 0, 3, 3
        end
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    context "scale up, label, float as world coordinate" do

      will_expect_big_string do
        <<-HERE
          ¦+--------+¦
          ¦|        |¦
          ¦|  xyz   |¦
          ¦|        |¦
          ¦+--------+¦
        HERE
      end

      given_choices do |o|
        o.pixels_wide = 10
        o.pixels_high = 5
      end

      given_shapes_layers do |sls|

        sls.width_height 3, 3

        sls.add_layer do |o|
          o.add_rect 0, 0, 3, 3
          o.add_label 0, 0, 3, 3, 'xyz'
        end
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    # ==

    context "scale down, label, fill" do

      will_expect_big_string do
        <<-HERE
          ¦                            ¦
          ¦                            ¦
          ¦          +--------------+  ¦
          ¦          |::frufamshi:::|  ¦
          ¦          +--------------+  ¦
        HERE
      end

      given_choices do |o|
        o.pixels_wide = 28
        o.pixels_high = 5
        o.background_fill_glyph = ':'
      end

      given_shapes_layers do |sls|

        sls.width_height 33, 13

        sls.add_layer do |o|
          o.add_rect 12, 6, 19, 9
          o.add_label 12, 6, 19, 9, 'frufamshi'
        end
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    # ==

    define_method :_this_one_big_stringer, (
        method_definition_for_big_stringer_for do
      <<-HERE
         ¦  +------------+            ¦
         ¦  |  jumanji   |            ¦
         ¦  |       +--------------+  ¦
         ¦  +-------|  frufamshi   |  ¦
         ¦          +--------------+  ¦
      HERE
        end
    )

    context "one layer on top of another" do

      given_choices do |o|
        o.pixels_wide = 28
        o.pixels_high = 5
      end

      given_shapes_layers do |sls|

        sls.width_height 33, 13

        sls.add_layer do |o|
          o.add_rect 3, 0, 17, 12
          o.add_label 3, 0, 17, 12, 'jumanji'
        end

        sls.add_layer do |o|
          o.add_rect 12, 6, 19, 9
          o.add_label 12, 6, 19, 9, 'frufamshi'
        end
      end

      def big_stringer
        _this_one_big_stringer
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    # ==

    # ==

    # ==
  end
end
