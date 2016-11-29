require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - horizontal meter integration" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    same_first_two_columns_and_beginning_design = -> defn do

      defn.separator_glyphs(
        NOTHING_, SPACE_ * 2, NOTHING_,
      )

      defn.add_field(
        :right,
        :label, "Subproduct",
      )

      defn.add_field(
        :label, "num test files",
      )

      defn.target_final_width 43
    end

    context "as model" do

      it "subject is a public model" do
        _subject_module || fail
      end

      it "builds" do
        _subject
      end

      it "trivial example - for now, uses `String#%` semantics" do

        _s = _subject % 8
        _s == "++++xxxxxxxx" || fail
      end

      shared_subject :_subject do
        _subject_module.define do |o|
          o.background_glyph 'x'
          o.denominator 24  # but imagine some irrational number
          o.target_final_width 12  # it's cheating until etc
        end
      end
    end

    same_matrix = [
      [ 'face', 121 ],
      [ 'headless', 44.0 ],
    ]

    context "max share meter built manually" do

      # (the first tombstone has the direct old counterpart to this.)

      it "(builds)" do
        design_ish_
      end

      it "(bytes are correct)" do

        against_matrix_expect_lines_ same_matrix do |y|
          y << "Subproduct  num test files                 "
          y << "      face           121    +++++++++++++++"
          y << "  headless            44.0  +++++          "
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          same_first_two_columns_and_beginning_design[ defn ]

          defn.add_field_observer(
            :_this_max_,
            :for_input_at_offset, 1,
          ) do |o|
            max = 0.0
            o.on_typified_mixed do |tm|
              if tm.is_numeric && max < tm.value
                max = tm.value
              end
            end
            o.read_observer_by do
              max
            end
          end

          defn.add_field(
            :fill_field,
            :order_of_operation, 0,
          ) do |col_rsx|

            w = col_rsx.width_allocated_for_this_column

            _denom = col_rsx.read_observer :_this_max_

            meter_format = _subject_module.define do |o|

              # o.foreground_glyph ; o.background_glyph (we take defaults for now)

              o.denominator _denom

              o.target_final_width w
            end

            empty_placeholder = SPACE_ * w

            -> row_rsx do

              tm = row_rsx.row_typified_mixed_at 1
              if tm.is_numeric
                meter_format % tm.value
              else
                empty_placeholder
              end
            end
          end
        end
      end
    end

    subject_module = -> do
      Home_::CLI::HorizontalMeter
    end

    same_design_using_prepackaged = -> defn do

      same_first_two_columns_and_beginning_design[ defn ]

      subject_module[].add_max_share_meter_field_to_table_design defn do |o|

        o.for_input_at_offset 1
        o.foreground_glyph '•'
        o.background_glyph '-'
      end
    end

    context "max share meter experimental pre-packaged" do

      # (the first tombstone has the direct old counterpart to this.)

      it "(builds)" do
        design_ish_
      end

      it "(bytes are correct)" do

        against_matrix_expect_lines_ same_matrix do |y|

          y << "Subproduct  num test files                 "
          y << "      face           121    •••••••••••••••"  # for now
          y << "  headless            44.0  •••••----------"
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          same_design_using_prepackaged[ defn ]
        end
      end
    end

    context "as above, integrate with a summary row" do

      # (the first tombstone has the direct old counterpart to this.)

      it "(builds)" do
        design_ish_
      end

      it "(bytes are correct)" do

        against_matrix_expect_lines_ same_matrix do |y|

          y << "Subproduct  num test files                 "
          y << "      face           121    •••••••••••••••"
          y << "  headless            44.0  •••••----------"
          y << "   (total)           165.0                 "
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          same_design_using_prepackaged[ defn ]

          _subject_module::For_table_design_add_total_summary_row_for_column.
            call( defn, 1, '(total)' )
        end
      end
    end

    define_method :_subject_module, subject_module
  end
end
# #tombstone during unification rewite for new API. spirit is same.
