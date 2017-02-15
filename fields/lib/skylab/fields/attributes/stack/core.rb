module Skylab::Fields

  class Attributes::Stack  # :[#028].

    class << self
      def common_frame * a
        if a.length.zero?
          Here_::CommonFrame
        else
          Here_::CommonFrame.call_via_arglist a
        end
      end
    end  # >>

    def initialize namelist=nil, & oes_p
      @a = []
      @d = -1
      @on_event_selectively = oes_p
      if namelist
        push_frame Here_::Lib_::Name_frame_via_namelist[ namelist ]
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
      push_frame Here_::Lib_::Frame_via_iambic[ x_a ]
    end

    def push_frame_via_box bx
      push_frame Here_::Lib_::Frame_via_box[ bx ]
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

    Here_ = self
  end
end
