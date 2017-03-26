module Skylab::Human

  module ExpressionPipeline_

    class IdeaArgumentAdapter_via_Verbish___  # #cov1.7

      # -
        class << self

          def via__argument_scanner__ scn
            x = scn.gets_one
            if x.respond_to? :ascii_only?
              new x
            else
              self._COVER_ME__when_lemma_is_not_string_symbol_would_be_fine__
            end
          end
          private :new
        end  # >>

        attr_reader :lemma_string

        def initialize s
          @lemma_string = s
        end

        def slot_symbol
          :verb_argument
        end
      # -
    end
  end
end
