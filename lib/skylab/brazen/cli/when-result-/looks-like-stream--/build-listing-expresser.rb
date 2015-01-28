module Skylab::Brazen

  class CLI

    module When_Result_::Looks_like_stream__

      class Build_listing_expresser

        Callback_::Actor.call self, :properties,

          :expag, :first_item

        def execute

          _FIELD_I_A, _FORMAT_H = build_black_and_white_property_formatters

          post_first_item = false

          -> entity, y do

            if post_first_item
              y << YAML_SEPARATOR__
            else
              post_first_item = true
            end

            _FIELD_I_A.each do | sym |

              y << _FORMAT_H.fetch( sym ) % entity.property_value_via_symbol( sym )

            end

            ACHIEVED_
          end
        end

        YAML_SEPARATOR__ = '---'.freeze

        def build_black_and_white_property_formatters

          prps = @first_item.class.properties.to_a

          fmt = property_value_format_string_via_props prps

          field_i_a = [] ; format_h = {}

          prps.each do | prp |
            sym = prp.name.as_lowercase_with_underscores_symbol
            field_i_a.push sym
            format_h[ sym ] = "#{ fmt % prp.name.as_human }: %s"
          end

          [ field_i_a, format_h ]
        end

        def property_value_format_string_via_props props
          d = props.reduce 0 do | m, prp |
            d_ = prp.name.as_human.length
            m < d_ ? d_ : m
          end
          "%#{ d }s"
        end
      end
    end
  end
end
