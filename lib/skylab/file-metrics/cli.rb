module Skylab::FileMetrics

  class CLI # < Brazen_::CLI

    class Action_Adapter
    end

    if false  # (tmp)

    Build_custom_lipstick_field = -> do

      o = {}

      o[ :header ] = EMPTY_S_

      o[ :is_autonomous ] = true

      o[ :cook ] = -> col_width_a, seplen do

        # given the widths of all the columns (and the width of the separator
        # that will go between each of them), build the proc that will render
        # the "lipstick" given a normal scalar. to do this we need to access
        # the "expression width" (probably screen width or the like).

        _w = Lipstick__::EXPRESSION_WIDTH_PROC[]

        len = col_width_a.length
        available_width = if len.zero?
          0
        else
          taken_width = col_width_a.reduce :+
          if len.nonzero?
            taken_width += ( seplen * ( len - 1 ) )
          end
        end

        if 1 < available_width

          lipstick_p = Lipstick__.new_expressor_with(
            :expression_width, available_width )

          -> scalar_pxy do

            lipstick_p[ scalar_pxy.normalized_scalar ]
          end
        else
          MONADIC_EMPTINESS_
        end
      end

      o
    end

    Lipstick__ = LIB_.brazen::CLI::Expression_Frames::Lipstick.build_with(
      :segment,
        :glyph,'+',
        :color, :green,
      :expression_width_proc, -> { 160 } )

    Client = self  # #tmx-compat

    end  # (tmp)
  end
end
