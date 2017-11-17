module Skylab::Cull

  class Models_::Mutator

    class Items__::Split_and_promote_property

      class << self

        def curry

          -> prp_s, x, sep_s do
            new prp_s, x, sep_s
          end
        end
      end

      def initialize prp_s, x, sep_s
        @prp_sym = prp_s.intern
        @split_rx = /[ \t]*#{ ::Regexp.escape sep_s }[ \t]*/
        @x = x
      end

      def [] ent, & p

        prp = ent.actual_property_via_name_symbol @prp_sym
        if prp

          ent.remove_property prp

          prp.value.split( @split_rx ).each do | s |
            ent.add_actual_property_value_and_name @x, s.intern
          end
        end

        nil
      end
    end
  end
end
