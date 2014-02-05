module Skylab::Headless

  module NLP

    module EN

      module Levenshtein

        # we love levenshtein
        # reduce a big list to a small list
        #
        #     Closest_items_to_item = Headless::NLP::EN::Levenshtein::
        #       With_conj_s_render_p_closest_n_items_a_item_x.
        #         curry[ ' or ', -> x { x.inspect }, 3 ]
        #     a = [ :zepphlyn, :beefer, :bizzle, :bejonculous, :wangton ]
        #     strange_x = :bajofer
        #     or_s = Closest_items_to_item[ a, strange_x ]
        #
        #     msg = "'#{ strange_x }' was not found. did you mean #{ or_s }?"
        #     msg # => "'bajofer' was not found. did you mean :beefer, :bizzle or :wangton?"

        With_conj_s_render_p_closest_n_items_a_item_x =
            -> conj, render_p, closest_n, item_a, outside_x do
          if (( a = Closest_n_items_to_item__[ closest_n, item_a, outside_x ] ))
            a.map!( & render_p )
            EN::Minitesimal::FUN.oxford_comma[ a, conj ]  # glob `conj` when ready
          end
        end
        #
        Closest_n_items_to_item__ = Headless::Library_::InformationTactics::
          Levenshtein::Closest_n_items_to_item

        Or_with_closest_n_items_to_item =
          With_conj_s_render_p_closest_n_items_a_item_x.
            curry[ ' or ', IDENTITY_ ]
      end
    end
  end
end
