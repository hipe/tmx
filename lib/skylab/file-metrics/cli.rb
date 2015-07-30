module Skylab::FileMetrics

  class CLI < lib_.brazen::CLI

    class << self
      def new * a
        new_top_invocation a, Home_.application_kernel_
      end
    end  # >>

    def expression_agent_class
      self.class.superclass.expression_agent_class
    end

    Build_custom_lipstick_field = -> o do

      o.edit_table_field(
        :no_data,
        :field,
        :celify, -> cel_element, metrix, for_dao do

          # (this code is based off the spec near "celify")
          # given the width of each column (and the width of the glyphs
          # that will separate them and flank them variously), and as
          # well the "expression area" (the entire width of the rendering
          # area available to us), build the proc that will render the
          # "lipstick" of each normal scalar.

          available_w = metrix.width - metrix.width_so_far
          s = cel_element.mutable_string

          if 1 < available_w

            if for_dao

              lipstick_p = Lipsticker.new_expressor_with(
                :expression_width, available_w )

              -> dao do

                s.replace lipstick_p[ dao.normal_share ]
                NIL_
              end
            else
              -> do
                s.replace SPACE_ * available_w
                NIL_
              end
            end
          else
            if for_dao
              MONADIC_EMPTINESS_
            else
              EMPTY_P_
            end
          end
        end
      )
    end

    Lipsticker = LIB_.brazen::CLI::Expression_Frames::Lipstick.build_with(
      :segment,
        :glyph,'+',
        :color, :green,
      :expression_width_proc, -> { 160 } )
  end
end
