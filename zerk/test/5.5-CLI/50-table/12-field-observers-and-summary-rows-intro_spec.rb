require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  C_EF_T_S_Struct__ = ::Struct.new :x, :y  # meh

  describe "[br] - CLI support - table - structured" do

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

    def _fake_data_stream * s_a_a

      _a = s_a_a.map do | s_a |
        C_EF_T_S_Struct__.new( * s_a )
      end

      Common_::Stream.via_nonsparse_array _a
    end

    def _begin_table
      Home_::CLI_Support::Table::Structured.new
    end

    def _line_expector_via_array y

      _st = Common_::Stream.via_nonsparse_array y

      TestSupport_::Expect_Line::Scanner.via_stream _st
    end
  end
end
