module Skylab::Brazen

  class Entity::Properties_Stack__

    module Models__

      Frame_via_Box__ = ::Class.new

      Frame_via_box = Frame_via_Box__.method :new

      Frame_via_Hash__ = ::Class.new

      Frame_via_hash = Frame_via_Hash__.method :new

      Frame_via_iambic = -> x_a do
        h = {}
        x_a.each_slice 2 do |i, x|
          h[ i ] = x
        end
        Frame_via_hash[ h ]
      end

      Name_Frame__ = ::Class.new

      Name_frame_via_namelist = Name_Frame__.method :new

      # ~

      class Frame_via_Box__

        def initialize bx
          @bx = bx
          @on_event_selectively = nil
        end

        def any_all_names
          @bx.a_
        end

        def all_names
          @bx.a_
        end

        def any_proprietor_of i
          if @bx.has_name i
            self
          end
        end

        def property_value_via_symbol i
          @bx.fetch i
        end
      end

      class Frame_via_Hash__

        def initialize h
          @h = h
          @on_event_selectively = nil
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

        def property_value_via_symbol i
          @h.fetch i
        end
      end

      class Name_Frame__

        def initialize i_a  # mutates
          @i_a = i_a.freeze
          @h = ::Hash[ i_a.map { |i| [ i, nil ] } ]
          @on_event_selectively = nil
        end

        def all_names
          @i_a
        end

        def any_proprietor_of i
          nil
        end

        def property_value_via_symbol i
          raise ::KeyError
        end
      end
    end
  end
end
