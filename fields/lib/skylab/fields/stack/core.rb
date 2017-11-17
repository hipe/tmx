module Skylab::Fields

  class Stack  # :[#028].

    # LEGACY (used maybe 1x in real life)

    # -
      def initialize namelist=nil, & p
        @a = []
        @d = -1
        @listener = p
        if namelist
          push_frame Name_frame_via_namelist___[ namelist ]
        end
      end

      def dereference sym

        pptr = any_proprietor_of sym

        if pptr

          pptr.dereference sym

        else
          maybe_send_event :error, :unrecognized_argument do

            Home_::Events::Extra.with :unrecognized_token, sym
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

        maybe_send_event :error, :unrecognized_argument do

          Home_::Events::Extra.with :unrecognized_tokens, xtra_a
        end

        UNABLE_
      end

      def maybe_send_event * i_a, & ev_p  # #[#ca-066]
        if @listener
          @listener.call( * i_a, & ev_p )
        elsif :error == i_a.first
          # (half of a [#co-045])
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
          @listener = nil
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

        def dereference i
          @bx.fetch i
        end
      end

    # ==

      class Frame_via_Hash__

        def initialize h
          @h = h
          @listener = nil
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

        def dereference i
          @h.fetch i
        end
      end

    # ==

      class Name_Frame__

        def initialize i_a  # mutates
          @i_a = i_a.freeze
          @h = ::Hash[ i_a.map { |i| [ i, nil ] } ]
          @listener = nil
        end

        def all_names
          @i_a
        end

        def any_proprietor_of i
          nil
        end

        def dereference i
          raise ::KeyError
        end
      end

    # ==
  end
end
# #history: what was originally "stack" became "toolkit". this used to be "lib-"
