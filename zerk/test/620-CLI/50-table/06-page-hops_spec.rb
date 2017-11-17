require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - page hops" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    context "default (and currently only) resize-model is \"grow\" (not shrink)" do

      it "pages widen (if necessary) over hops" do

        _matr = [
          %w( r1c1 r1c2 ),
          %w( r2c1x r2c2x ),
          %w( r3c1xx r3c2xx ),
          %w( r4c1x r4c2x ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| r1c1  | r1c2  |'
          y << '| r2c1x | r2c2x |'
          y << '| r3c1xx | r3c2xx |'
          y << '| r4c1x  | r4c2x  |'
        end
      end

      it "pages don't EVER narrowen over hops (not even a word)" do

        _matr = [
          %w( r1c1 r1c2 ),
          %w( r2c1xx r2c2xx ),
          %w( r3c1 r3c2 ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| r1c1   | r1c2   |'
          y << '| r2c1xx | r2c2xx |'
          y << '| r3c1   | r3c2   |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.page_size 2
        end
      end
    end

    context "a header row adds width put doesn't count as a page row" do

      it "width added by a header isn't forgotten over a page hop" do

        _matr = [
          %w( r1c1 r1c2 ),
          %w( r2c1 r2c2 ),
          %w( r3c1 r3c2 ),
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "| header 1 | header 2 |"
          y << "| r1c1     | r1c2     |"
          y << "| r2c1     | r2c2     |"
          y << "| r3c1     | r3c2     |"
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field :label, "header 1"

          defn.add_field :label, "header 2"

          defn.page_size 2
        end
      end
    end
  end
end
# #born: during final integration of [tab]
