module Skylab::Cull

  class Models_::Mutator

      Items__::Remove_empty_actual_properties = -> ent, & oes_p do

        st = ent.to_actual_property_stream

        index = -1

        d_a = nil

        while prp = st.gets

          index += 1

          x = prp.value

          if ! x || x.length.zero?
            d_a ||= []
            d_a.push index
          end
        end

        if d_a
          ent.remove_properties_at_indexes d_a
        else
          ACHIEVED_
        end
      end
  end
end
