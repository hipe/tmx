module Skylab::Fields

  MetaMetaFields = ::Module.new

  module MetaMetaFields::Enum
    # ->
      module Normalize_via_qualified_known ; class << self

        # assumes `enum_box` (values ignored) as part of the qkn assoc.

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
            bx.get_names,
            qkn.association.name_function,
          ]
          _
        end
      end ; end

      Build_extra_value_event = -> (
        x,
        valid_x_a,
        property_name,
        event_name_symbol=:invalid_property_value
      ) do

        Callback_::Event.inline_not_OK_with(

          event_name_symbol,
          :x, x,
          :property_name, property_name,
          :enum_value_polymorphic_streamable, valid_x_a,
          :error_category, :argument_error

        ) do | y, o |

          x = o.enum_value_polymorphic_streamable

          x_a = ::Array.try_convert x
          if ! x_a
            x_a = x.flush_remaining_to_array
          end

          _expecting = if x_a.length.zero?
            EMPTY_S_
          else
            " #{ x_a * ' | ' } "
          end

          y << "invalid #{ o.property_name.as_human } #{ ick o.x }, #{
            }expecting {#{ _expecting }}"
        end
      end
    # -
  end
end
