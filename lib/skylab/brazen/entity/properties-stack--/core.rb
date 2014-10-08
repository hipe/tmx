module Skylab::Brazen

  class Entity::Properties_Stack__

    class << self

      def build_extra_properties_event name_i_a

        Event_[].inline_with :extra_properties,
            :name_i_a, name_i_a,
            :error_category, :argument_error,
            :ok, false do |y, o|

          s_a = o.name_i_a.map( & method( :ick ) )

          y << "unrecognized #{ plural_noun 'property', s_a.length }#{
           } #{ and_ s_a }"

        end
      end

      def common_frame * a
        if a.length.zero?
          self::Common_Frame__
        else
          self::Common_Frame__.via_arglist a
        end
      end
    end

    def initialize event_receiver=nil
      @a = []
      @event_receiver = event_receiver
      @d = -1
    end

    def property_value i
      pptr = any_proprietor_of i
      if pptr
        pptr.property_value i
      else
        _ev = self.class.build_extra_properties_event [ i ]
        send_event _ev
      end
    end

    def any_proprietor_of i
      d = @d
      while -1 != d
        x = @a.fetch( d ).any_proprietor_of i
        x and break
        d -= 1
      end
      x
    end

    def push_frame_with * x_a
      push_frame Pstack_::Models__::Frame_via_iambic[ x_a ]
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
      _ev = Pstack_.build_extra_properties_event xtra_a
      send_event _ev
    end

    def send_event ev
      if @event_receiver
        @event_receiver.receive_event ev
      else
        raise ev.to_exception
      end
    end

    Pstack_ = self
  end
end
