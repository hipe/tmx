module Skylab::Fields

  module CommonMetaAssociations::Enum

    when_failed = nil

    Parse = -> ai do  # association interpreter

      n11n = ai.current_normalization_

      ary = n11n.argument_scanner.gets_one

      box = Lazy_.call do
        bx = Common_::Box.new
        ary.each do |x|
          bx.add x, nil
        end
        bx
      end

      _ca = n11n.entity  # current association

      _ca.argument_value_consumer_by_ do |_atr|

        -> x, p do

          bx = box[]
          if bx.has_key x  # as #here

            write_association_value_ x
          else

            _qkn = Common_::QualifiedKnownKnown.via_value_and_symbol x, :attribute_value

            when_failed[ _qkn, bx, & p ]
          end
        end
      end
    end

    Normalize_via_qualified_known = -> qkn, & p do

      # assumes `enum_box` (values ignored) as part of the qkn assoc.

      if qkn.is_known_known

        bx = qkn.association.enum_box

        if bx.has_key qkn.value  # as #here
          qkn.to_knownness
        else
          when_failed[ qkn, bx, & p ]
        end
      else

        # if this field is not required, no one wants its absence to
        # trigger enumeration membership failure. so we pass it on..

        qkn.to_knownness
      end
    end

    when_failed = -> qkn, bx, & p do

      build_the_event = -> do
        Here_::Build_extra_value_event.call(  # 1x
          qkn.value,
          bx.get_keys,
          qkn.association.name,
        )
      end

      if p

        p.call :error, :invalid_attribute_value do
          build_the_event[]
        end  # result is unreliable

        UNABLE_
      else
        raise build_the_event[].to_exception
      end
    end

    Here_ = self
  end
end
