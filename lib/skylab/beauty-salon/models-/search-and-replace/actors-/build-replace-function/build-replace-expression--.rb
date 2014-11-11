module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_replace_function

      class Build_replace_expression__

        Callback_::Actor.call self, :properties,

          :capture_identifier,
          :method_call_chain,
          :as_normal_value,
          :on_event_selectively

        def execute
          _x = Replace_Expression__.new @method_call_chain, @capture_identifier
          @as_normal_value[ _x ]
        end

        class Replace_Expression__ < ::BasicObject

          # proof of concept class. currently not robust, secure, scalable

          def initialize * a
            @method_call_chain, capture_identifier = a
            @d = capture_identifier.to_i
          end

          def call md
            @method_call_chain.reduce md[ @d ] do | x, method_s |
              __send__ method_s, x
            end
          end

          def downcase s
            s.downcase
          end

          def upcase s
            s.upcase
          end
        end
      end
    end
  end
end
