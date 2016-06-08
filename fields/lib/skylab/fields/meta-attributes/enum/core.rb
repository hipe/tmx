module Skylab::Fields

  module MetaAttributes::Enum

    when_failed = nil

    Parse = -> build do

      ary = build.sexp_stream_for_current_attribute.gets_one

      box = Lazy_.call do
        bx = Common_::Box.new
        ary.each do |x|
          bx.add x, nil
        end
        bx
      end

      _ca = build.current_attribute

      _ca.writer_by_ do |_atr|

        -> x, oes_p do

          bx = box[]
          if bx.has_name x  # as #here

            accept_attribute_value x
            KEEP_PARSING_
          else

            _qkn = Common_::Qualified_Knownness.via_value_and_symbol x, :attribute_value

            when_failed[ _qkn, bx, & oes_p ]
          end
        end
      end
    end

    Normalize_via_qualified_known = -> qkn, & oes_p do

      # assumes `enum_box` (values ignored) as part of the qkn assoc.

      if qkn.is_known_known

        bx = qkn.association.enum_box

        if bx.has_name qkn.value_x  # as #here
          qkn.to_knownness
        else
          when_failed[ qkn, bx, & oes_p ]
        end
      else

        # if this field is not required, no one wants its absence to
        # trigger enumeration membership failure. so we pass it on..

        qkn.to_knownness
      end
    end

    when_failed = -> qkn, bx, & oes_p do

      build_the_event = -> do
        Here_::Build_extra_value_event.call(
          qkn.value_x,
          bx.get_names,
          qkn.association.name,
        )
      end

      if oes_p

        oes_p.call :error, :invalid_attribute_value do
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
