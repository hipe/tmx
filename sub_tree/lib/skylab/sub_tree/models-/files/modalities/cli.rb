module Skylab::SubTree

  module Models_::Files

    module Modalities::CLI

      Actions = ::Module.new  # THE_EMPTY_MODULE_

      class Render_table < Common_::Actor::Dyadic

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

          string_matrix = []

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

            string_matrix.push cel_a
          end

          string_matrix
        end

        TWO_SPACES___ = '  '

        def __render_table_via_row_string_array string_matrix

          _Zerk_lib = Home_.lib_.zerk

          _design = _Zerk_lib::CLI::Table::Design.define do |o|

            o.separator_glyphs EMPTY_S_, EMPTY_S_, NEWLINE_

            o.add_field :left
            o.add_field :left
          end

          _mt_st = Common_::Stream.via_nonsparse_array string_matrix

          st = _design.line_stream_via_mixed_tuple_stream _mt_st
          y = @downstream_yielder
          while line = st.gets
            y << line
          end
          y
        end
      end
    end
  end
end

# #tombstone: [#br-093]:#case-study-st-2 ("when to subclass expression agents"
#             [#br-093]:#point-10 is relevant here (expag state)
