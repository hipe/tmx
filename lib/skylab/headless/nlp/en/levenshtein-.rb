module Skylab::Headless

  module NLP

    module EN

      module Levenshtein_

        # we love levenshtein
        # reduce a big list to a small list
        #
        #     Or_ = Headless::NLP::EN::Levenshtein_::Templates_::Or_
        #     a = [ :zepphlyn, :beefer, :bizzle, :bejonculous, :wangton ]
        #     strange_x = :bajofer
        #     or_s = Or_[ a, strange_x, 3, -> x { x.inspect } ]
        #
        #     msg = "'#{ strange_x }' was not found. did you mean #{ or_s }?"
        #     msg # => "'bajofer' was not found. did you mean :beefer, :bizzle or :wangton?"

        module Templates_

          p = -> conj, render_p, closest_n, item_a, outside_x do
            if (( a = Lev_[ closest_n, item_a, outside_x ] ))
              a.map!( & render_p )
              EN::Minitesimal::FUN.oxford_comma[ a, conj ]
            end
          end

          inner_or = p.curry[ ' or ' ]

          Or_ = -> item_a, outside_x, closest_n=3, rndr_p=MetaHell::IDENTITY_ do
            inner_or[ rndr_p, closest_n, item_a, outside_x ]
          end
        end

        Lev_ = Headless::Services::Levenshtein_
      end
    end
  end
end
