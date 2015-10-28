module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON

      class Express

        def initialize & p
          @be_pretty = true
          @on_event_selectively = p
        end

        attr_writer(
          :be_pretty,
          :downstream_IO_proc,
          :upstream_component,
        )

        def execute

          ok = __resolve_whole_string
          ok && __resole_downstream_IO
          ok && __flush
        end

        def __resolve_whole_string

          s = build_string
          if s
            @_whole_string = s
            ACHIEVED_
          else
            s
          end
        end

        def build_string

          _h = _recurse @upstream_component

          _m = @be_pretty ? :pretty_generate : :generate

          Home_.lib_.JSON.send _m, _h
        end

        def _recurse compound

          h = {}  # we care that hashes are ordered here (for first time ever)

          st = ACS_::Reflection::To_qualified_knownness_stream[ compound ]
          begin
            kn = st.gets
            kn or break

            x = if kn.is_known_known
              kn.value_x
            end

            if x && ACS_::Reflection::Component_is_compound[ kn ]
              x = _recurse x
            end

            h[ kn.name.as_variegated_symbol ] = x

            redo
          end while nil

          h
        end
      end
    end
  end
end
