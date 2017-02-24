require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - magnetics - item reference via token stream" do

    TS_[ self ]
    use :magnetics, :item_reference_via_token_stream

    context 'two words (produce unassociated)' do

      given_parse do
        input_words 'foo', 'bar'
      end

      it "parses" do
        item_parse_tree || fail
      end

      it "'unassociated' is the category symbol" do
        _category_symbol == :unassociated || fail
      end

      it "knows its own name ('term_symbol') (and that's it)" do
        _term_symbol == :foo_bar || fail
      end
    end

    context "simple 'as'" do

      given_parse do
        input_words 'fliff', 'as', 'blam'
      end

      it "parses" do
        item_parse_tree || fail
      end

      it "its category symbol is.." do
        _category_symbol == :manner || fail
      end

      it "it knows the 'slot' and 'particular' names" do
        o = item_parse_tree
        o.slot_term_symbol == :fliff || fail
        o.manner_term_symbol == :blam || fail
      end
    end

    context "simple 'via'" do

      given_parse do
        input_word_array %w(foo bar via biff bazz)
      end

      it "parses" do
        item_parse_tree || fail
      end
    end

    context "'via' with multiple 'via' fails" do

      given_parse do
        input_word_array %w( foo via bar via baz )
      end

      it "fails to parse" do
        item_parse_fails
      end

      it "didn't expect this token" do
        expect_unexpected_token_cateogory_ :via
      end

      it "expected these tokens" do
        expect_expected_token_categories_ :other, :and, :end
      end

      it "this explanation (byte-for-byte)" do

        expect_failure_message_lines_ do |y|

          y << "did not expect to encounter keyword 'via' at this point."
          y << "expected 'and', a business word or end of input."
        end
      end
    end

    context "'via' with 'and' and compound terms" do

      given_parse do
        input_word_array %w( a b and c and d e via f g and h )
      end

      it "parses" do
        item_parse_tree || fail
      end
    end

    context "(failure edges)" do

      it "'via' after 'as' fails (expects these things)" do

        input_word_array %w( a as b via c )
        expect_unexpected_token_cateogory_ :via
        expect_expected_token_categories_ :other, :end
      end

      it "'as' after 'via' fails (expects these things)" do

        input_word_array %w( a via b as c )
        expect_unexpected_token_cateogory_ :as
        expect_expected_token_categories_ :and, :other, :end
      end

      it "what if the input stream fails? (then no events from us)" do

        input_word_drama :word, "a", :word, "b", :fail, :word, "c"
        item_parse_tree_state.is_presumably_upstream_failure || fail
      end
    end

    context "(parse edges)" do

      it "'as' multiword-second-term parses" do

        input_word_array %w( a as b c )
        item_parse_tree || fail
      end
    end

    def _category_symbol
      item_parse_tree.category_symbol
    end

    def _term_symbol
      item_parse_tree.term_symbol
    end

  end
end
