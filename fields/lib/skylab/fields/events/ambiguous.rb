module Skylab::Fields

  module Event_  # #[#sl-0155]

    Home_::Events::Ambiguous = Common_::Event.prototype_with(

      :ambiguous_property,

      :x, nil,
      :name_string_array, nil,
      :name, nil,
      :error_category, :argument_error,
      :ok, false

    ) do | y, o |

      _s_a = o.name_string_array.map( & method( :val ) )

      name = o.name
      name ||= Common_::Name.via_variegated_symbol DEFAULT_PROPERTY_LEMMA_

      y << "ambiguous #{ o.name.as_human } #{ ick o.x } - did you mean #{ or_ _s_a }?"

    end

    class << Events::Ambiguous

      def via_arglist a, & slug
        new( * a, & slug )
      end

      def new ent_a, x, lemma_x=nil, & slug  # custom `new` near #[#co-070.2]

        if ! slug
          slug = -> ent do
            ent.name.as_slug
          end
        end

        _name_s_a = ent_a.map do | ent |
          slug[ ent ]
        end

        _name = if lemma_x
          if lemma_x.respond_to? :id2name
            Common_::Name.via_variegated_symbol lemma_x
          else
            lemma_x
          end
        end

        with(
          :x, x,
          :name_string_array, _name_s_a,
          :name, _name )
      end
    end
  end
end
