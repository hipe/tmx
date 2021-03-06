module Skylab::Arc

  module Operation

    class WhenNotAvailable < ::ArgumentError

      Require_fields_lib_[]

      Act = -> p, unava_p, fo do

        # so many permutations. is mentee of #here-1

        x = unava_p.call
        if p
          if x
            ( * sym_a, ev_p ) = x
            p.call( * sym_a, & ev_p )
            UNABLE_
          else
            self._B
          end
        else
          if x

            # #C15n-test-family-5 in [hu]

            ( * sym_a, ev_p ) = x

            o = Home_.lib_.human::NLP::EN::Contextualization.begin

            o.given_emission sym_a, & ev_p

            o.exception_class = WhenNotAvailable

            _ev = o.to_exception

          else
            _ev = Build_event[ fo ].to_exception
          end
          raise _ev
        end
      end

      Build_event = -> fo do

        o = Field_::CommonMetaAssociations::Enum::Build_extra_value_event.new

        o.adjective = nil  # override 'invalid'

        o.event_name_symbol = :operation_not_available

        o.property_name = Common_::Name.via_human 'operation'

        o.invalid_value = fo.name.as_slug

        o.predicate_string = 'is not available'

        o.valid_collection = nil

        o.exception_class_by = -> { Home_::NotAvailable }

        o.execute
      end
    end
  end
end
