require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (public) - ASCII matrix via shapes layers - depth" do

    TS_[ self ]
    use :memoizer_methods
    Home_.lib_.treemap.test_support::Common_Magnets_And_Models[ self ]
    use :mondrian_ASCII

    context "depth" do

      given_mondrian_tree do

        _qt = groceries_A_quantity_tree

        _ = mondrian_tree_via_quantity_tree _qt do |o|
          o.target_rectangle = 5, 2
          o.portrait_landscape_threshold_rational = squareish_in_ASCII_
        end
        _  # #todo
      end

      given_choices do |o|
        o.pixels_wide = 25
        o.pixels_high = 10
      end

      will_expect_big_string do
        <<-HERE
          ¦+----------++-------++--+¦
          ¦|          ||       ||  |¦
          ¦|  flour   || milk  ||eg|¦
          ¦|          ||       ||  |¦
          ¦+----------+|       ||  |¦
          ¦+------++--++-------++--+¦
          ¦|      ||  |+-----------+¦
          ¦| corn ||br||   yohoo   |¦
          ¦|      ||  ||           |¦
          ¦+------++--++-----------+¦
        HERE
      end

      it "every byte is correct" do
        want_every_byte_is_correct_
      end
    end

    # ==

    # ==
  end
end
