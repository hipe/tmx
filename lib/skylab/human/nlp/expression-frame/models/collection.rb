module Skylab::Human

  class NLP::Expression_Frame

    Models = ::Module.new

    class Models::Collection

      class << self

        def new_via_module mod
          new mod
        end

        private :new
      end  # >>

      def initialize mod
        @_mod = mod
      end

      def expression_frame_via_iambic x_a

        best_match = nil
        box_mod = @_mod
        idea = EF_::Models_::Idea.new_via_iambic x_a

        box_mod.constants.each do | const |
          x = box_mod.const_get const, false
          match = x.match_for_idea idea
          if match
            if best_match
              if best_match <= match
                best_match = match
              end
            else
              best_match = match
            end
          end
        end

        if best_match
          best_match.to_expression_frame
        else
          self._LOGIC_HOLE
        end
      end
    end
  end
end
