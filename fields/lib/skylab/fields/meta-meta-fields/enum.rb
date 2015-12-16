module Skylab::Brazen

  module Entity

    Meta_Meta_Properties = ::Module.new

    module Meta_Meta_Properties::Enum

      module Normalize_via_qualified_known ; class << self

        def _call qkn, & oes_p

          if qkn.is_known_known
            ___against_known_known qkn, & oes_p
          else
            # if this field is not required, no one wants its absence to
            # trigger enumeration membership failure. so we pass it on..
            qkn.to_knownness
          end
        end
        alias_method :[], :_call
        alias_method :call, :_call

        def ___against_known_known qkn, & oes_p

          enum_bx = qkn.association.enum_box

          if enum_bx.has_name qkn.value_x
            qkn.to_knownness
          else
            ___when_failed qkn, enum_bx, & oes_p
          end
        end

        def ___when_failed qkn, enum_bx, & oes_p

          p = -> { ___build_event qkn, enum_bx }

          if oes_p

            _unreliable = oes_p.call :error, :invalid_property_value do
              p[]
            end

            UNABLE_
          else
            raise p[].to_exception
          end
        end

        def ___build_event qkn, bx

          _ = Build_extra_value_event[
            qkn.value_x,
            qkn.association.name_function,
            bx.get_names,
          ]
          _
        end
      end ; end

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
