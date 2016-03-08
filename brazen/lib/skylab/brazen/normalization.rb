module Skylab::Brazen

  module Home_::Normalization  # see [#087]

    Against_model_stream = -> entity_x, formal_prp_st, & oes_p do  # see [#087]

      miss_prp_a = nil

      o = Build_Knownness_Normalizer__.new

      o.apply_default = -> model do
        model.default_value_via_entity_ entity_x
      end

      o.when_missing = -> kn, _, & ev_p do

        # don't stop cold on these - aggregate and procede.
        ( miss_prp_a ||= [] ).concat ev_p[].miss_a
        kn
      end

      o.on_event_selectively = oes_p
      normalize_knownness = o.flush

      kn = ACHIEVED_  # if there are no formal properties, watch what happens

      begin

        prp = formal_prp_st.gets
        prp or break

        kn = entity_x.knowness_via_association_ prp

        if kn.is_known_known
          was_known = true
          orig_x = kn.value_x
        else
          was_known = false
        end

        kn = normalize_knownness[ kn, prp ]
        kn or break

        yes = nil
        if was_known
          if kn.is_known_known
            if orig_x != kn.value_x
              yes = true
            end
          else
            self._STRANGE
          end
        elsif kn.is_known_known
          yes = true
        end

        # (it may be that it was not known and it is not known)

        if yes
          _ = entity_x.set_value_of_formal_property_ kn.value_x, prp
          _ or self._NEVER  # #todo - assume this always succeeds?
        end

        redo
      end while nil

      if miss_prp_a
        entity_x.receive_missing_required_properties_array miss_prp_a
      elsif kn
        ACHIEVED_
      else
        kn
      end
    end

    class Build_Knownness_Normalizer__  # #[#087].

      attr_writer(
        :apply_default,
        :on_event_selectively,
        :when_missing,
      )

      def flush

        Require_fields_lib_[]

        -> kn, model, & x_p do

          # 1. if value is unknown and defaulting is available, apply it.

          if ! kn.is_effectively_known && Field_::Has_default[ model ]

            kn = kn.new_with_value @apply_default[ model ]
          end

          # (it may be that you don't know the value and there is no default)

          # 2. if there are ad-hoc normalizations, apply those. (was [#ba-027])

          bx = model.ad_hoc_normalizer_box
          if bx
            kn = __add_hocs kn, bx, model, & x_p
          end

          # 3. if this is a required property and it is unknown, act.
          #    (skip this if the field failed a normalization above.)

          if kn

            if ! kn.is_effectively_known && Field_::Is_required[ model ]

              kn = @when_missing.call kn, MISSING___ do

                Home_.lib_.fields::Events::Missing.for_attribute model
              end
            end
          end

          kn
        end
      end

      MISSING___ = [ :error, :missing_required_properties ].freeze

      def __add_hocs kn, bx, model, & x_p

        # ad-hocs need to know the property too (née "trios not pairs")

        bx.each_value do | norm_norm_p |

          # at each step, value might have changed. [#053]

          _qkn = kn.to_qualified_known_around model

          kn = norm_norm_p[ _qkn, & ( x_p || @on_event_selectively ) ]  # (was [#072])
          kn or break
          kn.is_qualified and self._SHAPE_ERROR_we_want_QKNs_in_and_KNs_out
        end

        kn
      end
    end

    o = Build_Knownness_Normalizer__.new

    o.apply_default = -> model do

      self._K

      # model.default_value_  # <- more like this
      # model.default_value_via_entity_ entity_x  # <- less like this
    end

    o.when_missing = -> kn, _, & ev_p do

      self._K

      # ev_p[].miss_a
    end

    o.on_event_selectively = nil
    Against_model = o.flush
  end
end
