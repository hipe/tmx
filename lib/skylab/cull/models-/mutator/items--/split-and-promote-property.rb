module Skylab::Cull

  class Models_::Mutator

      Items__::Split_and_promote_property = -> ent, prp_s, x, sep_s, & oes_p do

        prp = ent.actual_property_via_name_symbol prp_s.intern
        if prp

          ent.remove_property prp

          s_a = prp.value_x.split sep_s
          s_a.each do | s |
            s.strip!
            ent.add_actual_property_value_and_name x, s.intern
          end
        end

        nil
      end
  end
end
