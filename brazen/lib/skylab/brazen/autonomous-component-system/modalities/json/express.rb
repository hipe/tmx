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
          :upstream_ACS,
        )

        def execute

          ok = __resolve_whole_string
          ok && __resolve_downstream_IO
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

          _h = _recurse @upstream_ACS

          _m = @be_pretty ? :pretty_generate : :generate

          Home_.lib_.JSON.send _m, _h
        end

        def _recurse compound

          h = {}  # we care that hashes are ordered here (for first time ever)

          o = nil
          store = -> x do
            h[ o.name.as_variegated_symbol ] = x ; nil
          end

          st = ACS_::Reflection::To_qualified_knownness_stream[ compound ]
          begin
            o = st.gets
            o or break

            # if it's a known unknown for now we store null for more detail..

            if ! o.is_known_known
              store[ nil ] ; redo
            end

            # if it's nil or false *and* it's known, easy - store as is

            x = o.value_x
            if ! x
              store[ x ] ; redo
            end

            # if it's a compound component, always recurse

            mdl = o.association.component_model
            if ACS_::Reflection::Model_is_compound[ mdl ]
              _x = _recurse x
              store[ _x ] ; redo
            end

            # it's gotta be either a trueish primitive or it's what we're
            # calling a "heavy atomic". against all decency (would go up):

            case x
            when ::TrueClass, ::Fixnum, ::Float, ::String
              store[ x ] ; redo
            else
              _x = x.to_component_value
              store[ _x ] ; redo
            end
          end while nil

          h
        end

        # ~

        def __resolve_downstream_IO

          io = @downstream_IO_proc[]
          if io
            @_downstream_IO = io
            ACHIEVED_
          else
            io
          end
        end

        # ~

        def __flush

          io = remove_instance_variable :@_downstream_IO

          bytes = io.write "#{ @_whole_string }#{ NEWLINE_ }"  # [#sn-020]

          io.close  # result is nil

          @on_event_selectively.call :info, :wrote do

            Home_.lib_.system.filesystem_lib.event( :Wrote ).new_with(
              :bytes, bytes,
              :path, io.path,
            )
          end

          ACHIEVED_  # don't result in bytes, it's confusing
        end

        attr_reader(
          :downstream_IO,  # experimental..
        )
      end
    end
  end
end
