module Skylab::Brazen

  module Property  # :+#stowaway

    class << self

      def build_ambiguous_property_event *a
        Build_ambiguous_property_event___[ *a ]
      end

      def build_extra_values_event *a
        Build_extra_properties_event___[ *a ]
      end

      def build_missing_required_properties_event *a
        Build_missing_required_properties_event___[ *a ]
      end
    end # >>
  end

  class Property::Stack  # :[#057].

    class << self
      def common_frame * a
        if a.length.zero?
          Pstack_::Models_::Common_Frame
        else
          Pstack_::Models_::Common_Frame.call_via_arglist a
        end
      end
    end  # >>

    def initialize namelist=nil, & oes_p
      @a = []
      @d = -1
      @on_event_selectively = oes_p
      if namelist
        push_frame Pstack_::Models_::Name_frame_via_namelist[ namelist ]
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
      push_frame Pstack_::Models_::Frame_via_iambic[ x_a ]
    end

    def push_frame_via_box bx
      push_frame Pstack_::Models_::Frame_via_box[ bx ]
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
    end

    def _build_extra_properties_event xtra_a
      Property.build_extra_values_event xtra_a
    end

    def maybe_send_event * i_a, & ev_p
      if @on_event_selectively
        @on_event_selectively.call( * i_a, & ev_p )
      elsif :error == i_a.first
        raise ev_p[].to_exception
      end
    end

    Pstack_ = self
  end

  module Property  # re-open

    Build_ambiguous_property_event___ = -> ent_a, x, lemma_x=nil do

      _slug_a = ent_a.map do | ent |
        ent.name.as_slug
      end

      if lemma_x
        _name = if lemma_x.respond_to? :id2name
          Callback_::Name.via_variegated_symbol lemma_x
        else
          lemma_x
        end
      end

      Callback_::Event.inline_with( :ambiguous_property,
        :x, x,
        :name_s_a, _slug_a,
        :name, _name,
        :error_category, :argument_error,
        :ok, false
      ) do | y, o |

        _s_a = o.name_s_a.map( & method( :val ) )

        name = o.name
        name ||= Callback_::Name.via_variegated_symbol DEFAULT_PROPERTY_LEMMA__

        y << "ambiguous #{ o.name.as_human } #{ ick o.x } - did you mean #{ or_ _s_a }?"

      end
    end

    Build_extra_properties_event___ = -> name_x_a, did_you_mean_i_a=nil, lemma=nil, adj=nil do

      Callback_::Event.inline_with :extra_properties,
          :name_x_a, name_x_a,
          :did_you_mean_i_a, did_you_mean_i_a,
          :lemma, lemma,
          :error_category, :argument_error,
          :ok, false do |y, o|

        s_a = o.name_x_a.map( & method( :ick ) )

        _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA__

        if adj.nil?
          adj_ = "unrecognized "
        elsif adj
          adj_ = "#{ adj } "
        end

        # e.g: "unrecognized property 'foo'"

        y << "#{ adj_ }#{ plural_noun s_a.length, _lemma }#{
          } #{ and_ s_a }"

        if o.did_you_mean_i_a
          _s_a_ = o.did_you_mean_i_a.map( & method( :code ) )
          y << "did you mean #{ or_ _s_a_ }?"
        end
      end
    end

    Build_missing_required_properties_event___ = -> miss_a, lemma=nil, nv=nil do

      Callback_::Event.inline_with :missing_required_properties,
          :miss_a, miss_a,
          :lemma, lemma,
          :nv, nv,
          :error_category, :argument_error,
          :ok, false do |y, o|

        s_a = o.miss_a.map do |prop|
          par prop
        end

        if o.nv
          _nv = "#{ o.nv }#{ SPACE_ }"
        end

        _lemma = o.lemma || DEFAULT_PROPERTY_LEMMA__

        y << "#{ _nv }missing required #{ plural_noun s_a.length, _lemma } #{
          }#{ and_ s_a }"
      end
    end

    DEFAULT_PROPERTY_LEMMA__ = 'property'.freeze

  end
end
