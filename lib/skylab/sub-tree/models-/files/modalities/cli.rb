module Skylab::SubTree

  module Models_::Files

    Modalities = ::Module.new

    module Modalities::CLI

      EXPRESSION_AGENT = class Expression_Agent___ < SubTree_::CLI::Expression_Agent

        # see [#hl-052]:#case-study-st-2 ("when to subclass expression agents")

        def express_into_yielder_line_items__ y, item_a
          Express_line_items___[ y, item_a ]
        end

        # ~ supplemental EN NLP

        SubTree_.lib_.EN_add_methods self, :private, %i( and_ both )

        self
      end.new nil  # [#hl-052]:#point-10 is relevant here (expag state)

      class Express_line_items___

        # if any of the activated extensions were #post-notifiees, here is
        # how we express this collection of "line items":

        Callback_::Actor.call self, :properties,

          :downstream_yielder,
          :line_item_array

        def execute

          __render_table_via_row_string_array __build_row_string_array
        end

        def __build_row_string_array

          row_s_a = []

          @line_item_array.each do | line_item |

            g_a, slug, any_leaf = line_item.to_a

            cel_a =
              [ "#{ "#{ g_a * SPACE_ } " if g_a.length.nonzero? }#{ slug }" ]

            cel_a.push( if any_leaf
              fs = any_leaf.any_free_cel
              if fs
                "#{ TWO_SPACES___ }#{ fs }"
              else
                EMPTY_S_
              end
            else
              EMPTY_S_
            end )

            row_s_a.push cel_a
          end

          row_s_a
        end

        TWO_SPACES___ = '  '

        def __render_table_via_row_string_array row_s_a

          SubTree_::Lib_::CLI_table[
            :field, :id, :glyphs_and_slug, :left,
            :field, :id, :xtra, :left,
            :show_header, false,
            :left, EMPTY_S_, :sep, EMPTY_S_, :right, "\n",
            :read_rows_from, row_s_a,
            :write_lines_to, @downstream_yielder ]

          ACHIEVED_
        end
      end
    end
  end
end
