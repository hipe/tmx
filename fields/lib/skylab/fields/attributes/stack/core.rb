module Skylab::Fields

  class Attributes::Stack  # :[#028].

    # LEGACY (used maybe 1x in real life)

    # -
      def initialize namelist=nil, & oes_p
        @a = []
        @d = -1
        @on_event_selectively = oes_p
        if namelist
          push_frame Name_frame_via_namelist___[ namelist ]
        end
      end

      def property_value_via_symbol sym

        pptr = any_proprietor_of sym

        if pptr

          pptr.property_value_via_symbol sym

        else
          maybe_send_event :error, :extra_properties do
            _build_extra_properties_event [ sym ]
          end
          UNABLE_
        end
      end

      def any_proprietor_of sym
        d = @d
        while -1 != d
          x = @a.fetch( d ).any_proprietor_of sym
          x and break
          d -= 1
        end
        x
      end

      def push_frame_with * x_a
        push_frame Frame_via_iambic___[ x_a ]
      end

      def push_frame_via_box bx
        push_frame Frame_via_box___[ bx ]
      end

      def push_frame x
        ok = true
        if @a.length.nonzero?
          a = x.any_all_names
          if a
            xtra_a = a - @a.first.all_names
            if xtra_a.length.nonzero?
              when_xtra xtra_a
              ok = false
            end
          end
        end
        if ok
          @a.push x
          @d += 1
        end
        ok
      end

    private

      def when_xtra xtra_a
        maybe_send_event :error, :extra_properties do
          _build_extra_properties_event xtra_a
        end
        UNABLE_
      end

      def _build_extra_properties_event xtra_a
        Home_::Events::Extra.build xtra_a
      end

      def maybe_send_event * i_a, & ev_p  # #[#ca-066]
        if @on_event_selectively
          @on_event_selectively.call( * i_a, & ev_p )
        elsif :error == i_a.first
          raise ev_p[].to_exception
        end
      end

    # -
    # ==

      Frame_via_Box__ = ::Class.new

      Frame_via_box___ = Frame_via_Box__.method :new

      Frame_via_Hash__ = ::Class.new

      frame_via_hash = Frame_via_Hash__.method :new

      Frame_via_iambic___ = -> x_a do
        h = {}
        x_a.each_slice 2 do |i, x|
          h[ i ] = x
        end
        frame_via_hash[ h ]
      end

      Name_Frame__ = ::Class.new

      Name_frame_via_namelist___ = Name_Frame__.method :new

    # ==

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
          if @bx.has_key i
            self
          end
        end

        def property_value_via_symbol i
          @bx.fetch i
        end
      end

    # ==

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

    # ==

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

    # ==
  end
end
# #history: what was originally "stack" became "toolkit". this used to be "lib-"
