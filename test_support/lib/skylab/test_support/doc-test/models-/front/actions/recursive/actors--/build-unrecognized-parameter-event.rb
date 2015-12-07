module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        Actors__::Build_unrecognized_parameter_event = -> ev, mod do

          ev.with do | y, o |

            ev.express_into_under y, self

            _item_s_a = mod.constants.map do | const_i |

              Callback_::Name.via_const_symbol( const_i ).
                as_lowercase_with_underscores_symbol.id2name

            end

            _reduced_s_a = Home_.lib_.human::Levenshtein.with(
              :item, o.name.id2name,
              :items, _item_s_a,
              :closest_N_items, 3,
              :item_proc, IDENTITY_,
              :aggregation_proc, IDENTITY_,
            )

            _inferred_tag_s_a = _reduced_s_a.map do | s |
              code "##{ s.gsub UNDERSCORE_, DASH_ }"
            end

            y << "did you mean #{ or_ _inferred_tag_s_a }?"

          end
        end
      end
    end
  end
end
