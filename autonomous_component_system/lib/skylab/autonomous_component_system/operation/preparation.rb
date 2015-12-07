module Skylab::Autonomous_Component_System

  # ->

    module Operation::Preparation  # notes in [#004]

      # the "operation" structure is pure model - it mostly just implements
      # the DSL for model-defined operations, but does not come with strong
      # opinions about how prepare calls to the "callable" it encapsulates.
      #
      # the subject, then, bridges the gap between that callable and the
      # syntax we chose to create for "edit sessions", which involves
      # special care near:
      #
      #   • required-ness,
      #   • globs,
      #   • real defaults/specified defaults
      #   • the implementation of named arguments on top of all the above
      #
      # this library has three exposures: one is as a typical session. the
      # other two of are to be used with the strange trick of duping and
      # extending to create a session, because of how many parameters are
      # shared by this concern and the client there.

      Common__ = ::Module.new

      class Session

        include Common__

        def operation= x
          @operation = x
          _init_box_via_operation
          NIL_
        end

        attr_writer(
          :arg_st,
        )

        attr_reader(
          :args,
        )
      end

      module Self_Methods

        include Common__

        def prepare
          _init_operation
          _prepare_args
        end
      end

      module Deep_Methods

        include Common__

        def prepare

          __init_next_ACS
          _init_operation
          _prepare_args
        end

        def __init_next_ACS

          _cmp = ACS_::For_Interface::Read_or_write[ @association, @ACS, & @oes_p ]
          @ACS = _cmp
          NIL_
        end
      end

      module Common__

        def _init_operation

          @operation = ACS_::Operation.via_symbol_and_ACS(
            @operation_symbol,
            @ACS,
          )

          _init_box_via_operation

          NIL_
        end

        def _init_box_via_operation
          @_bx = @operation.formal_properties_in_callable_signature_order
          NIL_
        end

        def _prepare_args

          if 1 == @_bx.length && Field_::Is_required[ @_bx.at_position( 0 ) ]
            __prepare_single_style
          else
            process_named_arguments
          end
        end

        def __prepare_single_style

          if @arg_st.unparsed_exists
            @args = [ @arg_st.gets_one ]
            ACHIEVED_
          else
            self._COVER_ME
          end
        end

        def process_named_arguments

          proto = @operation.prototype_parameter

          if proto && proto.default_proc
            __process_named_arguments_with_default_default proto

          else
            __process_named_arguments_feebly
          end
        end

        def __process_named_arguments_with_default_default proto  # see [#]note-B

          default_default = -> do
            x = proto.default_proc.call
            default_default = -> { x }
            x
          end

          args = []
          st = @_bx.to_value_stream
          wv_h = _slice_off_relevant_args

          begin

            par = st.gets
            par or break

            wv = wv_h[ par.name_symbol ]
            if wv
              x = wv.value_x

            elsif Field_::Is_required[ par ]
              self._COVER_ME_as_written
              raise ::ArgumentError, __say_missing( par, wv_h, st )

            elsif Field_::Has_default[ par ]
              x = par.default_proc[]
            else
              x = default_default[]
            end

            if Field_::Takes_many_arguments[ par ]
              self._HOLD_THE_PHONE
            end

            args.push x

            redo
          end while nil

          @args = args
          ACHIEVED_
        end

        def __say_missing par, wv_h, st
          a = [ par ]
          while par = st.gets
            wv_h[ par.name_symbol ] and next
            Field_::Is_required[ par ] or next
            a.push par
          end
          _say_missing a
        end

        def __process_named_arguments_feebly  # see [#]note-A

          # ~ local globals for work

          wv_h = _slice_off_relevant_args
          op_h = nil
          par = nil
          st = @_bx.to_value_stream
          wv = nil

          # ~ local globals for output

          args = []
          missing = nil
          ok = true  # in case there are no formal params, always OK

          # ~

          wrapped_value = nil ; when_missing = nil

          value_for_optional = nil
          value_for_glob = nil
          no_value_for_optional = nil

          op_h = {

            one: -> do  # `req`
              wv = wrapped_value[]
              if wv
                args.push wv.value_x
                KEEP_PARSING_
              else
                when_missing[]
              end
            end,

            zero_or_one: -> do  # `opt`
              wv = wrapped_value[]
              if wv
                value_for_optional[]
              else
                no_value_for_optional[]
              end
            end,

            zero_or_more: -> do  # `rest`

              op_h.delete :zero_or_more  # sanity
              wv = wrapped_value[]
              if wv
                value_for_glob[]
              else
                no_value_for_optional[]
              end
            end
          }

          wrapped_value = if wv_h
            -> do
              wv_h[ par.name_symbol ]
            end
          else
            EMPTY_P_
          end

          when_missing = -> do  # at the first missing required formal we
            # encounter we fail semi-immediately in this way: unwind the
            # remaining stream of formals looking for others like this to
            # aggregate the message; while disregarding all other formals.

            ok = false
            missing = [ par ]
            op_h = nil  # sanity
            while par = st.gets
              Field_::Is_required[ par ] or next
              wrapped_value[] and next
              missing.push par
            end
            UNABLE_
          end

          value_for_optional = -> do

            # as long as we haven't started using defaults,
            # we are OK to just to put these here

            args.push wv.value_x
            KEEP_PARSING_
          end

          value_for_glob = -> do

            args.concat wv.value_x  # oh man
            KEEP_PARSING_
          end

          no_value_for_optional = -> do  # see [#]note-A.2

            last_opt = nil

            same = -> do
              raise ::ArgumentError, __say_opt_hop( par, last_opt )
            end

            value_for_optional = same
            value_for_glob = same

            no_value_for_optional = -> do
              last_opt = par
              # no nothing, the platform will substitute the real default.
              KEEP_PARSING_
            end

            no_value_for_optional[]
          end

          begin
            par = st.gets
            par or break
            ok = op_h.fetch( par.parameter_arity ).call
            ok or break
            redo
          end while nil

          if ok
            @args = args
            ok
          elsif missing
            raise ::ArgumentError, _say_missing( missing )  # [#]note-C
          else
            self._COVER_ME
          end
        end

        def _say_missing missing

          _s_a = missing.map do | par |
            "`#{ par.name_symbol }`"
          end

          _ = "`#{ @operation.name_symbol }`"

          "call to #{ _ } missing required argument(s): (#{ _s_a * ', '})"
        end

        def __say_opt_hop par_, par

          "cannot have explicit value for `#{ par_.name_symbol }` #{
           }when no value is passed for `#{ par.name_symbol }` because #{
            }of our leaky isomorphism between methods and named args"
        end

        Field_ = Home_.lib_.fields  # idiomatic name

        def _slice_off_relevant_args

          # random access to name-value pairs to algorithms that want it.
          # argument arities of zero and one are recognized but no others.

          arg_st = @arg_st ; bx = @_bx.h_ ; h = nil

          begin
            if arg_st.no_unparsed_exists
              break
            end
            par = bx[ arg_st.current_token ]
            par or break

            arg_st.advance_one

            _x = if Field_::Takes_argument[ par ]
              arg_st.gets_one  # ..
            else
              true  # as flag
            end

            h ||= {}
            h[ par.name_symbol ] = Value_Wrapper[ _x ]
              # overwrite OK, NOTWITHSTANDING globs (be careful!)

            redo
          end while nil

          h
        end

        attr_reader(
          :args,
          :ACS,
          :operation,
        )
      end
    end
  # -
end
