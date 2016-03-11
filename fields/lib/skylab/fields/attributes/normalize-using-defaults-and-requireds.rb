module Skylab::Fields

  class Attributes

    yes = nil
    Normalize_using_defaults_and_requireds = -> sess do
      attrs = sess.class::ATTRIBUTES
      if attrs
        yes[ sess, attrs ]
      else
        ACHIEVED_
      end
    end

    yes = -> sess, attrs do
      # -
        miss_atr_a = nil

        atr = nil

        attrs = sess.class::ATTRIBUTES

        opt_h = attrs.optionals_hash || MONADIC_EMPTINESS_

        st = attrs.to_defined_attribute_stream

        begin
          atr = st.gets
          atr or break

          ivar = atr.as_ivar

          x = if sess.instance_variable_defined? ivar
            sess.instance_variable_get ivar
          else
            sess.instance_variable_set ivar, nil
          end

          if x.nil? && false && atr.default_proc  # LOOK
            x = atr.default_proc[]  # ..
            sess.instance_variable_set ivar, x
          end

          if x.nil? && ! opt_h[ atr.name_symbol ]
            ( miss_atr_a ||= [] ).push atr
          end

          redo
        end while nil

        if miss_atr_a
          ev = Home_::Events::Missing.for_attributes miss_atr_a
          # ..
          raise ev.to_exception
        else
          ACHIEVED_
        end
      end

      # KILL receive_missing_required_properties_event ev

      # KILL nilify_uninitialized_ivars
  end
end

# #history: broke out of sibling (originally from m-ethodic)
