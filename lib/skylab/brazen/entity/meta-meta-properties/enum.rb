module Skylab::Brazen

  module Entity

    Meta_Meta_Properties = ::Module.new

    module Meta_Meta_Properties::Enum

      Entity_against_meta_entity = -> prp, mprp, & oes_p do

        enum_bx = mprp.enum_box
        x = prp.send mprp.property_reader_method_name

        if x

          if enum_bx.has_name x
            prp
          else

            event = -> do
              Build_extra_value_event[ x, mprp.name, enum_bx.get_names ]
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
          prp  # whether or not this is a required field is not our concern
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
