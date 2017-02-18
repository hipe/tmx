require_relative '../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] iambic grammar - intro (to \"entity killer\")" do

    TS_[ self ]
    use :memoizer_methods
    use :iambic_grammar

    it "loads" do
      iambic_grammar_library_module || fail
    end

    context "a grammar for colors (terminal bag) and numbers (nonterminal)" do

      it "builds" do
        subject_grammar
      end

      context "red color only" do

        it "parses one item" do
          _subject.length == 1
        end

        it "the qualified item knows its injection identifer and content" do
          qual_item = _subject.fetch 0
          qual_item.injection_identifier == :_color_PA_ || fail
          qual_item.item == :red || fail
        end

        shared_subject :_subject do
          against :red
          _st = flush_to_stream
          _st.to_a
        end
      end

      it "color number number color number" do

        against :blue, :three, :one, :red, :two
        o = __flush_result
        o.colors == [ :blue, :red ] || fail
        o.numbers == [ 31, 2 ] || fail
      end

      shared_subject :subject_grammar do

        iambic_grammar_library_module.define do |o|

          o.add_grammatical_injection :_color_PA_, X_ig_i_Color

          o.add_grammatical_injection :_number_PA_, X_ig_i_Number
        end
      end
    end

    def __flush_result

      # (this is what the asset subject used to do on first swing)

      rslt = X_ig_i_Output.new
      st = flush_to_stream
      begin
        qualified_item = st.gets
        qualified_item || break
        case qualified_item.injection_identifier
        when :_color_PA_; rslt.__add_color qualified_item.item
        when :_number_PA_; rslt.__add_number qualified_item.item
        else never
        end
        redo
      end while above
      rslt
    end

    # ==

    class X_ig_i_Number

      class << self

        def is_keyword k
          :one == k || :two == k || :three == k
        end

        def gets_one_item_via_scanner scn
          total = 0
          begin
            d = case scn.head_as_is
            when :three ; 3 ; when :two ; 2 ; when :one ; 1
            end
            d || break
            total *= 10
            total += d
            scn.advance_one
          end until scn.no_unparsed_exists
          total
        end

      end  # >>
    end

    class X_ig_i_Color

      class << self

        def is_keyword k
          :red == k || :blue == k
        end

        def gets_one_item_via_scanner scn
          scn.gets_one
        end
      end  # >>
    end

    class X_ig_i_Output

      def initialize
        @colors = [] ; @numbers = []
      end

      def __add_color sym
        @colors.push sym ; TRUE
      end

      def __add_number d
        @numbers.push d ; TRUE
      end

      attr_reader :colors, :numbers
    end

    # ==
    # ==
  end
end
# #history: added a new file contemporary with the new work.
