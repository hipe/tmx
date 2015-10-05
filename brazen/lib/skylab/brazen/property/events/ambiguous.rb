module Skylab::Brazen

  module Property

    Events::Ambiguous = Callback_::Event.prototype_with(

      :ambiguous_property,

      :x, nil,
      :name_s_a, nil,
      :name, nil,
      :error_category, :argument_error,
      :ok, false

    ) do | y, o |

      _s_a = o.name_s_a.map( & method( :val ) )

      name = o.name
      name ||= Callback_::Name.via_variegated_symbol DEFAULT_PROPERTY_LEMMA_

      y << "ambiguous #{ o.name.as_human } #{ ick o.x } - did you mean #{ or_ _s_a }?"

    end

    class << Events::Ambiguous

      def new_via_arglist a
        __new_via( * a )
      end

      def __new_via ent_a, x, lemma_x=nil

        _name_s_a = ent_a.map do | ent |
          ent.name.as_slug
        end

        _name = if lemma_x
          if lemma_x.respond_to? :id2name
            Callback_::Name.via_variegated_symbol lemma_x
          else
            lemma_x
          end
        end

        new_with(
          :x, x,
          :name_s_a, _name_s_a,
          :name, _name )
      end
    end
  end
end
