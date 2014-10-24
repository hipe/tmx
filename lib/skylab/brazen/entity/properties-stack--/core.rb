module Skylab::Brazen

  class Entity::Properties_Stack__

    class << self

      def build_extra_properties_event *a
        Build_extra_properties_event__[ *a ]
      end

      def build_missing_required_properties_event *a
        Build_missing_required_properties_event__[ *a ]
      end

      def common_frame * a
        if a.length.zero?
          self::Common_Frame__
        else
          self::Common_Frame__.via_arglist a
        end
      end
    end

    DEFAULT_PROPERTY_LEMMA__ = 'property'.freeze

    def initialize event_receiver=nil, namelist=nil
      @a = []
      @event_receiver = event_receiver
      @d = -1
      if namelist
        push_frame Pstack_::Models__::Name_frame_via_namelist[ namelist ]
      end
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

    def push_frame_via_box bx
      push_frame Pstack_::Models__::Frame_via_box[ bx ]
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

    # ~

    Bound_properties = -> bp_p, properties do
      properties.to_scan.map_by do |prop|
        bp_p[ prop ]
      end.immutable_with_random_access_keyed_to_method :name_i
    end

    Build_extra_properties_event__ = -> name_i_a, did_you_mean_i_a=nil, lemma=nil, adj=nil do

      Event_[].inline_with :extra_properties,
          :name_i_a, name_i_a,
          :did_you_mean_i_a, did_you_mean_i_a,
          :lemma, lemma,
          :error_category, :argument_error,
          :ok, false do |y, o|

        s_a = o.name_i_a.map( & method( :ick ) )

        _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA__

        if adj.nil?
          adj_ = "unrecognized "
        elsif adj
          adj_ = "#{ adj } "
        end

        y << "#{ adj_ }#{ plural_noun _lemma, s_a.length }#{
          } #{ and_ s_a }"

        if o.did_you_mean_i_a
          _s_a_ = o.did_you_mean_i_a.map( & method( :code ) )
          y << "did you mean #{ or_ _s_a_ }?"
        end
      end
    end

    Build_missing_required_properties_event__ = -> miss_a, lemma=nil do

      Event_[].inline_with :missing_required_properties,
          :miss_a, miss_a,
          :lemma, lemma,
          :error_category, :argument_error,
          :ok, false do |y, o|

        s_a = o.miss_a.map do |prop|
          par prop
        end

        _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA__

        y << "missing required #{ plural_noun _lemma, s_a.length } #{
          }#{ and_ s_a }"
      end
    end

    Pstack_ = self
  end
end
