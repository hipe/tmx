module Skylab::Human

  module ExpressionPipeline_

    class QuadCount  # 1x. [here] only

      # (introduction to parent node at #spot1.6)

      # we find that a useful generalization of "count" is into these four
      # categories, the integer sets variously of 0, 1, 2 and
      # "more than two."
      #
      # this allows for both the code to be more readable and the frame of
      # thinking more consistent when we deal with the common issues of
      # how count is expressed with regards to both grammatical inflection
      # (the "singular" vs "plural" grammatical category of "number"
      # common in most (all?) romance languages and many others), as well
      # as the more surface yet still prevalent idioms that express
      # count, like the pronoun/adjective/adverb "both" and the noun "pair"
      # and the multifarious ways we express nothingness.
      #
      # as well we may use this "quad" classification to determine if a
      # list of items is too long to express inline as e.g the subject
      # of a sentence.

      module Common__

        def is_none
          false
        end

        alias_method :is_one, :is_none
        alias_method :is_more_than_one, :is_none
        alias_method :is_two, :is_none
        alias_method :is_more_than_two, :is_none
      end

      o =  {}

      o[ :none ] = module None___
        extend Common__
        class << self
          def is_none
            true
          end
        end  # >>
        self
      end

      o[ :one ] = module One___
        extend Common__
        class << self
          def is_one
            true
          end
        end  # >>
        self
      end

      o[ :two ]  = module Two___
        extend Common__
        class << self

          def is_more_than_one
            true
          end

          def is_two
            true
          end

        end  # >>
        self
      end

      o[ :more_than_two ] = module More__than_two
        extend Common__
        class << self

          def is_more_than_one
            true
          end

          def is_more_than_two
            true
          end
        end  # >>
        self
      end

      define_singleton_method :fetch do | k, & p |
        o.fetch k, & p
      end
    end
  end
end
