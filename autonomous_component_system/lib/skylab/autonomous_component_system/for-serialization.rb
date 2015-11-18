module Skylab::Autonomous_Component_System

  # ->

    module For_Serialization  # notes in [#003]

      To_stream = -> acs do

        if acs.respond_to? :to_stream_for_component_serialization
          acs.to_stream_for_component_serialization
        else
          Infer_stream[ acs ]
        end
      end

      # understanding of [#ca-004] qualified knownness is assumed

      Infer_stream = -> acs do  # [mt]

        # hand-write a map-reduce that only produces qkn's for entries
        # only of the `association` category and serialization intent.

        asc_for = Component_Association.reader_for acs

        qkn_for = ACS_::Reflection_::Reader[ acs ]

        st = ACS_::Reflection_::To_entry_stream[ acs ]

        Callback_.stream do

          begin

            entry = st.gets
            entry or break

            if :association != entry.category
              # (operations have no business with serialization)
              redo
            end

            asc = asc_for[ entry.name_symbol ]

            int = asc.intent
            if int && :serialization != int
              redo
            end

            qkn = qkn_for[ asc ]

            # whether or not this is a known known it MUST be your result
            # so that we can use this same stream for expressing serialized
            # payloads as well as interpreting them.

            break
          end while nil

          qkn
        end
      end
    end
  # -
end
