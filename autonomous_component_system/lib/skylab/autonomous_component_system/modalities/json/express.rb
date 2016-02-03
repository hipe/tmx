module Skylab::Autonomous_Component_System

  # ->

    module Modalities::JSON

      class Express  # notes in [#003]

        def initialize & p
          @be_pretty = true
          @customization_structure_x = nil
          @on_event_selectively = p
        end

        attr_writer(
          :be_pretty,
          :customization_structure_x,
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

          h = _recurse @customization_structure_x, @upstream_ACS

          if h

            _m = @be_pretty ? :pretty_generate : :generate

            Home_.lib_.JSON.send _m, h

          else
            THE_EMPTY_TIMES___  # [ze]
          end
        end

        THE_EMPTY_TIMES___ = '{}'

        def _recurse cust_x, acs  # see [#003]:on-JSON-expression

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

          st = Home_::For_Serialization::Stream.via_customization_and_ACS(
            cust_x, acs )

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

              redo  # nil is never stored per #nil-note
            end

            # if it's a true-ish compound component, always recurse

            _is = o.association.model_classifications.looks_compound
            if _is

              _cust_x_ = if cust_x
                self._K
              end

              x_ = _recurse _cust_x_, x
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
              if ! Looks_primitive__[ x_ ]
                self._COVER_ME_wrong_shape
              end
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
          s = remove_instance_variable :@_whole_string

          if io.respond_to? :write

            path = io.path  # for event

            bytes = io.write "#{ s }#{ NEWLINE_ }"  # [#sn-020]

            io.close  # result is nil

          else
            bytes = ___write_string_to_line_oriented_context io, s
          end

          @on_event_selectively.call :info, :wrote do

            Home_.lib_.system.filesystem_lib.event( :Wrote ).new_with(
              :bytes, bytes,
              :path, path,
            )
          end

          # we no longer result in the number of bytes from calls like these
          # because it's confusing. (N what? is this an exitstatus?)
          # nowadays it's becoming convention for performers that "write"
          # to act like `<<` and result in the argument context:
          io
        end

        def ___write_string_to_line_oriented_context io, s

          # if the context does not respond to `write` then it is assumed
          # to be something like an ::Enumerator::Yielder, array, string.
          #
          # these are the reasons this isn't just a one-liner:
          #
          #   • break up the big string into lines in a memory-efficient
          #     way (i.e don't just use split)
          #
          #   • still track the number of bytes "written"
          #
          #   • conditionally add the line terminator sequence.
          #     (we only check this on the last line because our string
          #      scanner guarantees that each line already has this
          #      terminating sequence except the last line.)

          bytes = 0

          st = Home_.lib_.basic::String.line_stream s
          line = st.gets

          accept_line = -> do
            bytes += line.length
            io << line ; nil
          end

          if line
            begin
              line_ = st.gets
              if line_
                accept_line[]
                line = line_
                redo
              end
              if NEWLINE_BYTE___ != line.getbyte( -1 )
                line.concat NEWLINE_  # ..
              end
              accept_line[]
              break
            end while nil
          end

          bytes
        end

        attr_reader(
          :downstream_IO,  # experimental..
        )
      end

      Looks_primitive__ = -> x do  # `nil` is NOT primitive by this definition!
        case x
        when ::TrueClass, ::Fixnum, ::Float, ::Symbol, ::String  # [#003]#trueish-note
          true
        else
          false
        end
      end

      NEWLINE_ = "\n"
      NEWLINE_BYTE___ = NEWLINE_.getbyte( 0 )
    end
  # -
end
