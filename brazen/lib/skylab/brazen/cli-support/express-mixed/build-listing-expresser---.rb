module Skylab::Brazen

  module CLI_Support

    class Express_Mixed

      class Build_listing_expresser___ < Common_::Dyadic  # :[#064].

        def initialize x, y
          @expag = x
          @first_item = y
        end

        def execute

          if @first_item.respond_to? :component_name_symbols
            self._REDO_FUN_ride_along  # (current work branch)
            __function_when_components
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
              @_ent.dereference sym
            end

          else

            pcls = Home_.lib_.fields::SimplifiedName

            @_prps = cls.members.map do |k|
              pcls.new k do end  # (no edit)
            end

            @_value_p = -> sym do
              @_ent[ sym ]
            end
          end

          NIL_
        end

        def property_value_format_string_via_props props
          d = props.reduce 0 do | m, prp |
            d_ = prp.name.as_human.length  # wormhole [#035]
            m < d_ ? d_ : m
          end
          "%#{ d }s"
        end

        # ~

        def __function_when_components

          express_item = -> comp, y do

            Recurse_into_component__[ comp, EMPTY_S_, y, '  ' ]
          end

          p = -> comp, y do

            x = express_item[ comp, y ]
            p = -> comp_, y_ do
              y_ << YAML_SEPARATOR__
              express_item[ comp_, y_ ]
            end
            x
          end

          -> comp, y do
            p[ comp, y ]
          end
        end

        Recurse_into_component__ = -> comp, margin_s, y, tab_s do

          next_margin = -> do
            s = "#{ margin_s }#{ tab_s }"
            next_margin = -> { s }
            s
          end

          st = comp.to_component_knownness_stream
          begin
            kn = st.gets
            kn or break

            cm = kn.association.component_model

            if kn.is_known_known
              x = kn.value_x
              if x
                if x.respond_to? :to_component_knownness_stream
                  y << "#{ margin_s }#{ kn.name.as_human }:"
                  Recurse_into_component__[ x, next_margin[], y, tab_s ]
                else
                  cm.express_primitive_text kn, margin_s, y, tab_s
                end
              else
                cm.express_falseish_text kn, margin_s, y, tab_s
              end
            else
              cm.express_unknown_text kn, margin_s, y, tab_s
            end
            redo
          end while nil
          y
        end
      end
    end
  end
end
