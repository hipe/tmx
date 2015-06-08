module Skylab::Brazen

  module Entity

    Meta_Meta_Properties = ::Module.new

    module Meta_Meta_Properties::Enum

      Normalize_via_qualified_known = -> qkn, & oes_p do

        enum_bx = qkn.model.enum_box

        if qkn.is_known_is_known && qkn.is_known

          if enum_bx.has_name qkn.value_x
            qkn
          else

            event = -> do
              Build_extra_value_event[
                qkn.value_x, qkn.model.name_function, enum_bx.get_names ]
            end

            if oes_p
              oes_p.call :error, :invalid_property_value do
                event[]
              end
            else
              raise event[].to_exception
            end
          end
        else
          qkn  # whether or not the field is required is not our concern
        end
      end

      Build_extra_value_event = -> x, property_name, valid_x_a do

        Callback_::Event.inline_not_OK_with(

          :invalid_property_value,
          :x, x,
          :property_name, property_name,
          :enum_value_array, valid_x_a,
          :error_category, :argument_error

        ) do | y, o |

          y << "invalid #{ o.property_name.as_human } #{ ick o.x }, #{
            }expecting { #{ o.enum_value_array * ' | ' } }"
        end
      end
    end
  end
end
