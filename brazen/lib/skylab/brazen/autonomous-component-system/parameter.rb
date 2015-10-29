module Skylab::Brazen

  module Autonomous_Component_System

    class Parameter  # a fresh take on an old hat

      class << self

        def collection_into_via_mutable_platform_parameters bx, a

          # every param except any trailing block has an isomorph

          if a.length.nonzero? && :block == a.last.first  # might not be used
            a.pop
          end

          h = bx.h_

          a.each do | cat, sym |
            existing = h[ sym ]
            if existing
              existing.send :"_when__#{ cat }__"
            else
              new do
                bx.add sym, self
                @name_symbol = sym
                send :"_when__#{ cat }__"
              end
            end
          end

          NIL_
        end

        private :new
      end  # >>

      def initialize & p
        instance_exec( & p )
      end

      # ~ arities & related

      def _when__opt__
        @_arity = :zero_or_one
        NIL_
      end

      def _when__req__
        @_arity = :one
        NIL_
      end

      def _when__rest__
        @_arity = :zero_or_more
        NIL_
      end

      def is_required
        :one == @_arity
      end

      def takes_many_arguments
        :zero_or_more == @_arity
      end

      def normal_arity  # experiment - in contrast to arg v. param arity
        @_arity
      end

      attr_reader(
        :name_symbol,
      )
    end
  end
end
