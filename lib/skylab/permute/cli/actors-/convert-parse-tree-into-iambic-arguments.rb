module Skylab::Permute

  class CLI

    class Actors_::Convert_parse_tree_into_iambic_arguments

      Callback_::Actor.call self, :properties,
        :x_a, :o_a

      def execute

        cat_bx = Callback_::Box.new

        st = Callback_::Stream.via_nonsparse_array @o_a

        cat = Category__.new st.gets.value_x, st.gets.value_x

        cat_bx.add cat.name_string, cat

        @_bx = cat_bx
        @_col = Home_.lib_.brazen::Collection_Adapters::Box_as_Collection[ cat_bx ]
        @_st = st

        ok = true
        begin

          pair_for_name = st.gets
          pair_for_name or break

          pair_for_value = st.gets

          ok = send :"__on__#{ pair_for_name.name_x }__",
            pair_for_value.value_x,
            pair_for_name.value_x

          ok or break
          redo
        end while nil

        ok && __finish
      end

      def __on__short_switch__ value_s, short_category_s

        _trio = Callback_::Qualified_Knownness.via_value_and_variegated_symbol(
          short_category_s, :category_letter )

        cat_o = Home_.lib_.brazen::Collection::Common_fuzzy_retrieve[
          _trio, @_col, & @on_event_selectively ]

        if cat_o
          cat_o.s_a.push value_s
          KEEP_PARSING_
        else
          cat_o
        end
      end

      def __on__long_switch__ value_s, long_partial_catgory_s

        _trio = Callback_::Qualified_Knownness.via_value_and_variegated_symbol(
          long_partial_catgory_s, :category_letter )

        cat_o = Home_.lib_.brazen::Collection::Common_fuzzy_retrieve.call(
          _trio, @_col ) do end

        if cat_o
          cat_o.s_a.push value_s

        else

          cat_o = Category__.new long_partial_catgory_s, value_s
          @_bx.add cat_o.name_string, cat_o
        end
        KEEP_PARSING_
      end

      def __finish

        _0 = :pair
        x_a = @x_a

        @_bx.each_value do | cat_o |

          _1 = cat_o.name_string

          cat_o.s_a.each do | value_s |

            x_a.push _0, _1, value_s
          end
        end

        ACHIEVED_
      end

      class Category__

        def initialize name_s, first_value_s

          @name_string = name_s
          @s_a = [ first_value_s ]
        end

        def name  # for fuzzy lookup
          @___nm ||= Callback_::Name.via_slug @name_string
        end

        attr_reader :name_string, :s_a
      end
    end
  end
end

