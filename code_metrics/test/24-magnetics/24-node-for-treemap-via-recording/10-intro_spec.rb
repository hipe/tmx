require_relative '../../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - node for treemap via recording" do

    TS_[ self ]
    use :memoizer_methods
    use :treemap_node

    it "loads" do
      Home_::Magnetics_::Node_for_Treemap_via_Recording || fail
    end

    context "work one" do

      it "works" do
        treemap_node_ || fail
      end

      it "root node has a long const name" do

        s = treemap_node_.label_string
        s || fail
        __const_name_is_this_long s, 4..6
      end

      it "every non-root child has a short name" do

        __expect_every_non_root_child_has_a_short_name
      end

      it "terminal nodes have weights" do

        __expect_every_non_root_terminal_child_has_weights
      end

      def treemap_node_
        treemap_node_01_faboozle
      end
    end

    def __expect_every_non_root_terminal_child_has_weights

      expect_of_every_non_root_child_ do |tr|
        if ! tr.has_children
          d = tr.main_quantity
          d || fail
          d.zero? && fail
        end
      end
    end

    def __expect_every_non_root_child_has_a_short_name

      expect_of_every_non_root_child_ do |tr|
        s = tr.label_string
        if ! s
          fail "no label at depth #{ depth_ }"
        end
        if s.include? CONST_SEP_
          fail "why include const sep? #{ s.inspect }"
        end
      end
    end

    def __const_name_is_this_long s, r

      _d = Home_.lib_.basic::String.count_occurrences_in_string_of_string(
        s, CONST_SEP_ )

      r.include? _d || fail
    end
  end
end
