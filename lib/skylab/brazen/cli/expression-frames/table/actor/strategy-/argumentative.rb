module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategy_::Argumentative < Strategy_::Common

      SUBSCRIPTIONS = [ :arity_for ]

      def arity_for sym
        self.class.__arity_for sym
      end

      class << self

        def __arity_for sym
          ( @___arity_index ||= __build_arity_index )[ sym ]
        end

        def __build_arity_index

          h = {}

          const_get(
            :PROPERTIES, false
          ).each_slice 4 do | _aa_, arity_sym, _prp_, name_sym |

            :argument_arity == _aa_ or raise ::ArgumentError
            :property == _prp_ or raise ::ArgumentError

            h[ name_sym ] = arity_sym
          end
          h
        end
      end
    end
  end
end
