module Skylab::SubTree

  module Models_::Files

    Modalities = ::Module.new

    module Modalities::CLI

      Actions = ::Module.new  # THE_EMPTY_MODULE_

      class Render_table < Callback_::Actor::Dyadic

        # if any of the activated extensions were #post-notifiees, here is
        # how we express this collection of "line items":

        def initialize downstream_yielder, line_item_array
          @downstream_yielder = downstream_yielder
          @line_item_array = line_item_array
        end

        def execute

          _ = ___build_row_string_array

          __render_table_via_row_string_array _
        end

        def ___build_row_string_array

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

          _ = Home_.lib_.brazen::CLI_Support::Table::Actor

          _[

            :left, EMPTY_S_, :sep, EMPTY_S_, :right, NEWLINE_,

            :header, :none,
            :field, :left,
            :field, :left,

            :read_rows_from, row_s_a,

            :write_lines_to, @downstream_yielder,
          ]
        end
      end
    end
  end
end

# #tombstone: [#br-093]:#case-study-st-2 ("when to subclass expression agents"
#             [#br-093]:#point-10 is relevant here (expag state)
