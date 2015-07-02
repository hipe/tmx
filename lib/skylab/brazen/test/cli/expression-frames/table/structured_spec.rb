require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  C_EF_T_S_Struct__ = ::Struct.new :x, :y  # meh

  describe "[fm] models - report - modalities - CLI - expression-frames - t" do

    it "by default it aligns right with reasonable glyphs. label." do

      tbl = _begin_table

      tbl.edit_table(
        :field, :named, :x,
        :field, :named, :y, :label, 'Hi'
      )

      _st = _fake_data_stream [ 'x1', 'y11' ], [ 'x2', 'y2' ]

      _y = tbl.express_into_line_context_data_object_stream [], _st

      o = _line_expector_via_array _y
      o << '|   X |   Hi |'
      o << '|  x1 |  y11 |'
      o << '|  x2 |   y2 |'
      o.expect_no_more_lines
    end

    it "it does NOT line up the decimals out of the box. glyphs. left align." do

      tbl = _begin_table

      tbl.edit_table(

        :left, '( ',
        :sep, ' ; ',
        :field, :named, :x,
        :left_aligned, :field, :named, :y,
        :right, ' )'
      )

      _st = _fake_data_stream [ 1.125, 2 ], [ 3.3, 44 ]

      _y = tbl.express_into_line_context_data_object_stream [], _st

      o = _line_expector_via_array _y
      o << '(     X ; Y  )'
      o << '( 1.125 ; 2  )'
      o << '(   3.3 ; 44 )'
      o.expect_no_more_lines
    end

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

    define_method :_common_tree, ( Callback_.memoize do

      _FM = Home_::Autoloader_.require_sidesystem :FileMetrics  # #todo - mock this?

      _T = _FM::Models_::Report::Actions::Line_Count::Totaller_class___[]

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

      Callback_::Stream.via_nonsparse_array _a
    end

    def _begin_table
      Home_::CLI::Expression_Frames::Table::Structured.new
    end

    def _line_expector_via_array y

      _st = Callback_::Stream.via_nonsparse_array y

      TestSupport_::Expect_Line::Scanner.via_stream _st
    end
  end
end
