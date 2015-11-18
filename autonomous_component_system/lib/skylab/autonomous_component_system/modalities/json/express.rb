module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON

      class Express  # notes in [#083]

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

          h = _recurse @upstream_ACS

          if h

            _m = @be_pretty ? :pretty_generate : :generate

            Home_.lib_.JSON.send _m, h

          else
            self._COVER_ME_no_data_at_all
          end
        end

        def _recurse acs  # see [#083]:on-JSON-expression

          result = nil

          o = nil
          store = -> xx do
            # only create the hash if there's something to put in it
            result = {}
            store = -> x do
              result[ o.name.as_variegated_symbol ] = x
              NIL_
            end
            store[ xx ]
          end

          st = ACS_::For_Serialization::To_stream[ acs ]

          begin
            o = st.gets
            o or break

            if ! o.is_known_known
              redo  # if it's a known unknown, don't write anything
            end

            x = o.value_x
            if ! x  # if it's false-ish, *even if it's a compound component*,

              if false == x
                store[ x ] ; redo  # false is always stored as-is
              end

              redo  # nil is never stored per #inout-A
            end

            # if it's a true-ish compound component, always recurse

            _is = o.association.model_classifications.looks_compound
            if _is

              x_ = _recurse x
              if x_
                store[ x_ ]
              end
              # it's possible that a recursion can
              # result in false-ish, as we might do below
              redo
            end

            # at this point we know it's true-ish and not a compound node:

            if Looks_primitive__[ x ]

              # if it's a primitive, store as-is
              store[ x ] ; redo

            else
              x_ = x.to_primitive_for_component_serialization
              Looks_primitive__[ x_ ] or self._COVER_ME_wrong_shape
              store[ x_ ] ; redo
            end
          end while nil

          result
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

        Looks_primitive__ = -> x do
          case x
          when ::TrueClass, ::Fixnum, ::Float, ::String  # [#]inout-C
            true
          else
            false
          end
        end
      end
    end
  end
end
