module Skylab::Autonomous_Component_System

  module Operation

    class NormalRepresentation_for_Proc___ < Normal_Representation_

      def initialize p, fo
        @formal_ = fo
        @_p = p
      end

      def desc_proc_
        NOTHING_
      end

      class Preparation < Preparation_

        def to_bound_call

          ok = check_availability_
          ok &&= ___normalize
          ok && __init_args_via_h
          ok && Common_::BoundCall[ @_args, @nr_._p, :call, & @call_handler_ ]
        end

        def ___normalize

          store = @parameter_store
          x = store.internal_store_substrate
          x.respond_to? :each_pair or self._SANITY
          @__h = x
          normalize_
        end

        def __init_args_via_h
          a = []
          h = remove_instance_variable :@__h
          st = @nr_.to_defined_association_stream_memoized_
          begin
            par = st.gets
            par or break
            x = h[ par.name_symbol ]
            if Field_::Takes_many_arguments[ par ]
              if x  # (pray that our glob logic is right)
                a.concat x
              end
            else
              a.push x
            end
            redo
          end while nil
          @_args = a ; nil
        end
      end

      def to_association_index_

        ACS_::Parameter::
          AssociationIndex_via_PlatformParameters_and_FormalOperation.
        call(
          @_p.parameters,
          @formal_,
        )
      end

      def begin_parameter_store_ & _call_handler
        Store___.new
      end

      attr_reader(
        :_p,
      )

      class Store___

        # unlike "random access" stores, the store for the proc-based
        # operation must express the positionality of each formal parameter
        # in its expression of the actual values. as explained in [#029],
        # whether or not an actual value is known for it, something must be
        # expressed for each "slot" (`nil` when unknown).

        def initialize
          @_h = {}
        end

        def accept_parameter_value x, par
          @_h[ par.name_symbol ] = x
          NIL_
        end

        def evaluation_proc
          method :evaluation_of
        end

        def evaluation_of par
          had = true
          x = @_h.fetch par.name_symbol do
            had = false
          end
          if had
            Common_::Known_Known[ x ]
          else
            Common_::KNOWN_UNKNOWN
          end
        end

        def internal_store_substrate
          @_h
        end

        def is_classesque
          false
        end

        # #history: assimilated to here from a dedicated file
      end
    end
  end
end
