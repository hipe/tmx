module Skylab::Headless

  module NLP

    module EN

      module Levenshtein_

        # we love levenshtein
        # reduce a big list to a small list
        #
        #     Or_ = Headless::NLP::EN::Levenshtein_::Template_::Or_
        #     a = [ :zepphlyn, :beefer, :bizzle, :bejonculous, :wangton ]
        #     strange_x = :bajofer
        #     or_s = Or_[ 3, a, strange_x, -> x { x.inspect } ]
        #
        #     msg = "'#{ strange_x }' was not found. did you mean #{ or_s }?"
        #     msg # => "'bajofer' was not found. did you mean :beefer, :bizzle or :wangton?"

        module Template_

          Or_ = -> closest_n, items_a, outside_x, render=MetaHell::IDENTITY_ do
            if (( a = Lev_[ closest_n, items_a, outside_x ] ))
              a.map!( & render )
              EN::Minitesimal::FUN.oxford_comma[ a, ' or ' ]
            end
          end
        end

        Lev_ = Headless::Services::Levenshtein_
      end
    end
  end
end
