require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - overview" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    it "loads" do
      table_module_ || fail
    end

    context "the default design" do

      it "rendering a table with no tuples results in no lines" do

        against_stream_expect_lines_ Common_::THE_EMPTY_STREAM do |y|
          NOTHING_
        end
      end

      it "default styling is evident in this minimal non-empty table" do

        against_tuples_expect_lines_ %w( a ) do |y|
          y << "| a |"
        end
      end

      it "with one more row and one more column, we can see columns line up" do

        against_tuples_expect_lines_ %w( Food Drink ), %w( donuts coffee ) do |y|
          y << "| Food   | Drink  |"
          y << "| donuts | coffee |"
        end
      end

      def design_ish_
        table_module_  # careful
      end
    end

    context "customize your design: separators" do

      it "builds" do
        design_ish_
      end

      it "probably fine" do
        des = design_ish_
        _ = [ des.left_separator, des.inner_separator, des.right_separator ].join
        _ == '(,)' || fail
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.separator_glyphs '(', ',', ')'

        end
      end
    end

    context "customize your design: specify field labels for a header row" do

      it "build" do
        design_ish_
      end

      it "money" do

        against_tuples_expect_lines_ %w( donuts coffee ) do |y|
          y << "(Eat   ,Swallow)"
          y << "(donuts,coffee )"
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.separator_glyphs '(', ',', ')'

          defn.add_field :label, "Eat"

          defn.add_field :label, "Swallow"
        end
      end
    end

    context "customize your design: change default alignment " do

      it "builds" do
        design_ish_
      end

      it "money" do

        against_tuples_expect_lines_ %w( donuts coffee ), %w( kale tea ) do |y|
          y << "(    Eat, Swallow )"
          y << "( donuts, coffee  )"
          y << "(   kale, tea     )"
        end
      end

      context "if you really wanted to, you can customize a customized design" do

        it "builds" do
          design_ish_
        end

        it "money" do

          _matr = [
            %w( aaaa bb ccc ),
            %w( ddddd e f )
          ]

          against_matrix_want_lines_ _matr do |y|

            y << "->   Eat;  Mouth;   hi <-"
            y << "->  aaaa;     bb;  ccc <-"
            y << "-> ddddd;      e;    f <-"
          end
        end

        shared_subject :design_ish_ do

          _otr = __this_design

          _otr.redefine do |defn|

            defn.separator_glyphs '-> ', ';  ', ' <-'

            defn.redefine_field 1, :right, :label, "Mouth"

            defn.add_field :label, "hi", :right
          end
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.separator_glyphs '( ', ', ', ' )'

          defn.add_field :label, "Eat", :right

          defn.add_field :label, "Swallow"
        end
      end

      alias_method :__this_design, :design_ish_
    end
  end
end
# #history: full rewrite during unification. came from [br]. was [dt]-synced.
