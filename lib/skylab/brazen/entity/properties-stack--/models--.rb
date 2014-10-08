module Skylab::Brazen

  class Entity::Properties_Stack__

    module Models__

      Frame_via_iambic = -> x_a do
        h = {}
        x_a.each_slice 2 do |i, x|
          h[ i ] = x
        end
        Frame_via_hash[ h ]
      end

      Frame_via_hash = -> h do
        Frame_via_Hash__.new h
      end

      class Frame_via_Hash__

        def initialize h
          @h = h
          freeze
        end

        def any_all_names
          all_names
        end

        def all_names
          @h.keys
        end

        def any_proprietor_of i
          if @h.key? i
            self
          end
        end

        def property_value i
          @h.fetch i
        end
      end
    end
  end
end
