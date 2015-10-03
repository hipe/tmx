module Skylab::Brazen

  class CLI

    module When_Result_::Looks_like_stream__

      class Build_listing_expresser

        Callback_::Actor.call self, :properties,

          :expag, :first_item

        def execute
          if @first_item.respond_to? :to_component_knownness_stream
            self._THIS #  __function_when_components
          else
            __function_when_line_up_columns
          end
        end

        def __function_when_line_up_columns

          _FIELD_I_A, _FORMAT_H = build_black_and_white_property_formatters

          post_first_item = false

          -> entity, y do

            if post_first_item
              y << YAML_SEPARATOR__
            else
              post_first_item = true
            end

            @_ent = entity

            _FIELD_I_A.each do | sym |

              y << _FORMAT_H.fetch( sym ) % @_value_p[ sym ]

            end

            ACHIEVED_
          end
        end

        YAML_SEPARATOR__ = '---'.freeze

        def build_black_and_white_property_formatters

          __init_via_signature_of_first_item

          fmt = property_value_format_string_via_props @_prps

          field_i_a = [] ; format_h = {}

          @_prps.each do | prp |
            sym = prp.name.as_lowercase_with_underscores_symbol
            field_i_a.push sym
            format_h[ sym ] = "#{ fmt % prp.name.as_human }: %s"
          end

          [ field_i_a, format_h ]
        end

        def __init_via_signature_of_first_item

          cls = @first_item.class

          if cls.respond_to? :properties

            @_prps = cls.properties.to_value_stream.to_a

            @_value_p = -> sym do
              @_ent.property_value_via_symbol sym
            end

          else

            pcls = Callback_::Actor::Methodic::Property

            @_prps = cls.members.map do | sym |
              pcls.new do
                @name = Callback_::Name.via_variegated_symbol sym
              end
            end

            @_value_p = -> sym do
              @_ent[ sym ]
            end
          end

          NIL_
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
