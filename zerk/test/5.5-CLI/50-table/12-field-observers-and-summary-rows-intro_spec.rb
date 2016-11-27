require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - field observers and summary rows intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    context "build field observers and summary row into the design" do

      it "builds" do
        design_ish_
      end

      it "here is the longhand form of making a \"total\" cel (summary row)" do

        # there is no shorthand yet, not sure if there ever will be #track [#057]

        _matr = [
          [ 'coffee', 7.23 ],
          [ 'donut', 2.78 ],
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| coffee    |  7.23 |'
          y << '| donut     |  2.78 |'
          y << '| (total)   | 10.01 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.separator_glyphs '| ', '   | ', ' |'

          defn.add_field_observer :zizzio, :observe_input_at_offset, 1 do |o|
            total = 0.0
            o.on_typified_mixed do |tm|
              if tm.is_numeric
                total += tm.value
              end
            end
            o.read_observer_by do
              total
            end
          end

          defn.add_summary_row do |o|
            o << "(total)"
            o << o.read_observer( :zizzio )
          end

        end  # design
      end  # shared subject
    end  # context

    if false
    it "summary. map. data tree." do

      tbl = _begin_table
      tbl.edit_table(
        :field, :named, :slug, :summary, -> t__ do
          _d = t__.sum_of( :count )
          "(hi#{ _d })"
        end,
        :field, :named, :count, :map, -> x do
          "{#{ x }}"
        end,
      )

      _y = tbl.express_into_line_context_data_tree [], _common_tree

      o = _line_expector_via_array _y
      o << '|   Slug |  Count |'
      o << '|      B |    {3} |'
      o << '|      A |    {2} |'
      o << '|  (hi5) |        |'
      o.expect_no_more_lines
    end

    it "edit. celify." do

      _Build_custom_field = -> o do
        o.edit_table_field(
          :field,
          :label, EMPTY_S_,
          :celify, -> cel_element, metrix, for_dao do

            available = metrix.width - metrix.width_so_far
            s = cel_element.mutable_string

            if for_dao

              -> dao do
                s.replace(
                  "(#{ '%6.2f' % ( dao.normal_share * 100 ) }%#{
                    } of #{ available })" )
                NIL_
              end
            else

              -> do
                s.replace "(#{ SPACE_ * ( " of #{ available }".length + 7 ) })"
                NIL_
              end
            end
          end
        )
      end

      tbl = _begin_table
      tbl.edit_table(

        :field, :named, :slug,

        :no_data,
        :field, :named, :freeform,
          :label, 'never see',
          :edit, _Build_custom_field
      )

      tbl.expression_width = 30

      _y = tbl.express_into_line_context_data_tree [], _common_tree

      o = _line_expector_via_array _y
      o << '|  Slug |  (             ) |'
      o << '|     B |  (100.00% of 17) |'
      o << '|     A |  ( 66.67% of 17) |'
      o.expect_no_more_lines
    end

    define_method :_common_tree, ( Common_.memoize do

      C_EF_T_S = Home_.lib_.basic::Tree::Totaller.new
      _T = C_EF_T_S

      t = _T.new
      t_ = _T.new
      t_.slug = 'A'
      t_.count = 2
      t.append_child_ t_
      t_ = _T.new
      t_.slug = 'B'
      t_.count = 3
      t.append_child_ t_
      t.finish
      t
    end )

    def _begin_table
      Home_::CLI_Support::Table::Structured.new
    end
    end  # if false
  end
end
# #history: arrived in new home during unification
