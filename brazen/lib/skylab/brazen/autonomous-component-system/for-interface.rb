module Skylab::Brazen

  module Autonomous_Component_System

    module For_Interface  # notes in [#083]

      fetch = nil ; upbind = nil

      Read_or_write = -> asc, acs, & oes_p do

        # #open :[#083]:issue-1: this effects a "crude autovivification" -
        # it builds a component for a missing member and stores it whether
        # or not it is ultimately necessary. we would like for it to work
        # like it does thru signals where it only sets the member when it
        # changes (etc), but this will be tricky; and we don't need it yet
        # in the "real world" anyway

        yes = false
        cmp = fetch.call asc, oes_p, acs do
          yes = true
        end

        if yes
          cmp = upbind[ asc, acs, & oes_p ]
          ACS_::Interpretation_::Write_value[ cmp, asc, acs ]
        end

        cmp
      end

      Touch = -> asc, acs, & oes_p do

        fetch.call asc, oes_p, acs do

          upbind[ asc, acs, & oes_p ]
        end
      end

      fetch = -> asc, oes_p, acs, & else_p do

        # if the component is stored as a member of the client, result is
        # the component. otherwise call the block.

        qkn = ACS_::Reflection_::Read[ asc, acs ]

        if qkn.is_effectively_known

          self._REVIEW

          qkn.value_x
        else
          else_p.call
        end
      end

      upbind = -> asc, acs, & oes_p do

        # create a new empty component that is bound to the client,
        # but is *NOT* (yet) stored as a member value of client!

        o = ACS_::Interpretation_::Universal_Build.new( asc, acs, & oes_p )

        o.use_empty_argument_stream

        o.wrap_handler_as_component_handler

        wv = o.execute

        wv && wv.value_x
      end

      To_stream = -> acs do

        if acs.respond_to? :to_stream_for_component_interface
          acs.to_stream_for_component_interface
        else
          Infer_stream[ acs ]
        end
      end

      Infer_stream = -> acs do

        # hand-write a map-reduce stream whereby for all entries of category
        # `operation` and for those entries of category `association` whose
        # component association states or implies an intent of `interface`,
        # produce a qualified knownness-like structure.

        # build the bound reader (one per category) lazily, only when the
        # ACS is found to define one or more entries of that category.

        entry = nil
        h = {}
        h[ :association ] = -> do

          asc_for = Component_Association.reader_for acs

          qkn_for = ACS_::Reflection_::Reader[ acs ]

          p = -> do
            asc = asc_for[ entry.name_symbol ]
            int = asc.intent
            if ! int || :interface == int
              qkn_for[ asc ]
            end
          end

          h[ :association ] = p
          p.call
        end

        h[ :operation ] = -> do

          operation_for = ACS_::Operation.reader_for acs

          p = -> do
            operation_for[ entry.name_symbol ]
          end

          h[ :operation ] = p
          p.call
        end

        st = ACS_::Reflection_::To_entry_stream[ acs ]

        Callback_.stream do

          # hand-write a map-reduce for clarity
          begin

            entry = st.gets
            entry or break

            qkn_ish = h.fetch( entry.category ).call
            qkn_ish or redo
            break

          end while nil

          qkn_ish
        end
      end
    end
  end
end
