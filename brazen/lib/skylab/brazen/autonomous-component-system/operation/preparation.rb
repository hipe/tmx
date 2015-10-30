module Skylab::Brazen

  module Autonomous_Component_System

    module Operation::Preparation

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
      #   • real defaults and
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

          _cmp = ACS_::Interpretation::Touch[ @association, @ACS, & @oes_p ]
          @ACS = _cmp
          NIL_
        end
      end

      module Common__

        def _init_operation

          @operation = ACS_::Operation.via_symbol_and_component(
            @operation_symbol,
            @ACS,
          )

          _init_box_via_operation

          NIL_
        end

        def _init_box_via_operation
          @_bx = @operation.formal_properties
          NIL_
        end

        def _prepare_args

          if 1 == @_bx.length && @_bx.at_position( 0 ).is_required
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

          # the objective is to implement the interpretation of named
          # arguments in such a way that uses the real defaults in the
          # signature while asserting the required parameters and
          # integrating any one glob parameter.
          #
          # towards using real defaults we cannot merely place the values
          # into a fixed-width array with holes left in it. rather we have
          # to "skip over" an entry for `opt` params that were not passed.
          #
          # the syntax of the platform language dictates that these "real"
          # defaults (`opt`) must always be contiguous with respect to one
          # another; and if there is a `rest` param along with them, it
          # must be placed immediately after them. but this "section" can
          # occur in front of, behind, or in the middle of the zero or more
          # `req` parameters.
          #
          # as such we do not assert that syntax here but assume it.

          # ~ local globals for work

          h = __slice_off_relevant_args
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

          wrapped_value = if h
            -> do
              had = true ; x = h.fetch( par.name_symbol ) { had = false }
              if had
                Value_Wrapper[ x ]
              end
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
              par.is_required or next
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

          no_value_for_optional = -> do

            # once you start (effectively) requesting platform ("real")
            # defaults by not passing an argument, you cannot stop using
            # defaults and go back to explicitly passing values for these
            # `opt` parameters because of a necessary asymmetry determined
            # by the platform syntax (because platform arguments are not
            # in fact named).

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
            ok = op_h.fetch( par.normal_arity ).call
            ok or break
            redo
          end while nil

          if ok
            @args = args
            ok
          elsif missing

            # it's the responsibility of the client to express validity in
            # its own modality appropriate way. if required parameters are
            # not passed at this low level it is deemed a failure at using
            # one's own internal API, and as such it is not appropriate to
            # emit an event. to raise an exception is useful for debugging.

            raise ::ArgumentError, __say_missing( missing )
          else
            self._COVER_ME
          end
        end

        def __say_missing missing

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

        def __slice_off_relevant_args

          arg_st = @arg_st ; bx = @_bx ; h = nil

          begin
            if arg_st.no_unparsed_exists
              break
            end
            par = bx[ arg_st.current_token ]
            par or break

            arg_st.advance_one
            k = par.name_symbol
            x = arg_st.gets_one

            h ||= {}
            h[ k ] = x  # overwrite OK, NOTWITHSTANDING globs (be careful!)

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
  end
end
