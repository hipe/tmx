module Skylab::Zerk

  class Invocation_::BuildState___

    # [#013] has an introduction to why & how we cache graph node solutions

    def initialize par, oper_index, pbc

      si = oper_index.scope_index_
      k = par.name_symbol
      @_modality_frame = si.modality_frame_via_node_name_symbol_ k
      @_node_reference = si.node_reference_via_node_name_symbol_ k
      @_parameter = par
      @_pbc = pbc
    end

    def execute
      _specialize
      _state_via_particular_execute
    end

    def begin_session__
      _specialize
      __particular_begin_customizable_session
    end

    def _specialize
      send @_node_reference.node_reference_category ; nil
    end

  private

     def association
       extend For_Association___
     end

     def operation
       extend For_Operation___
     end

  public

    def in_progress
      true
    end

    module For_Association___

      def _state_via_particular_execute

        # if we are at this point (and the association is being evaluated),
        # assume some operation's "stated" set refers to it. it is only at
        # this (late) point that we will confirm that it is the right shape
        # (if there is such a thing) to be an association that is depended
        # upon for the purposes of sharing.

        @_asc = remove_instance_variable( :@_node_reference ).association
        send @_asc.model_classifications.category_symbol
      end

      def primitivesque
        __atomesque
      end

      def entitesque
        self._COVER_ME_should_be_fine_just_follow_this
        __atomesque
      end

      def compound
        self._READ_027_why_we_do_not_approriate_compound_nodes
        # [#027]#"why we do not appropriate compound nodes"
      end

      def __atomesque

        # here's how we evaluate such an association: simply determine if
        # it's effectively known or not based solely on its value knownness
        # in The Store plus the smarts we add here about list-based nodes.

        kn = @_modality_frame.for_invocation_read_atomesque_value_ @_asc

        # we add an extra detail to determine knownness - if it is a list-
        # type field and its array is zero length, downgrade it so it
        # appears as known unknown at normalization algorithms..

        if kn.is_effectively_known  # if it is set and not nil
          Require_fields_lib_[]
          if Field_::Takes_many_arguments[ @_asc ]
            if kn.value.length.zero?
              kn = Common_::KNOWN_UNKNOWN
            end
          end
        end

        State__.new kn
      end
    end

    module For_Operation___

      def __particular_begin_customizable_session

        unava_p = _unavailability_proc
        if unava_p
          self._WEE
        else
          _init_procure_bound_call
          @_procure_bound_call.begin_customizable_session__
        end
      end

      def _state_via_particular_execute

        # if we are here than this is a dependency operation being evaluated
        # for one particular depender operation (of possibly several).
        #
        # whether it succeeds or fails, this evalution will be cached for
        # reuse by other nodes in this whole full-stack execution.

        unava_p = _unavailability_proc

        if unava_p
          self._COVER_AND_RETROFIT
          State_of_Net_Unavailable_Formal_Operation___
        else
          kn = ___knownness_when_available
          kn or self._SANITY
          State__.new kn
        end
      end

      def ___knownness_when_available  # the rest of this is near [#027]:"o.d"

        _init_procure_bound_call

        @_bc = @_procure_bound_call.execute

        if @_bc
          ___knownness_via_bound_call
        else
          _ = @_procure_bound_call.release_reasoning_
          Common_::KnownUnknown.via_reasoning _
        end
      end

      def ___knownness_via_bound_call

        # this is at the behest of *another* operation; so whereas
        # "procure bound call" is procuring a bound call, here we just
        # always call it right now (or similar).

        @_name_symbol = @_fo.name_symbol
        rs = @_procure_bound_call.real_store_
        if rs.is_classesque
          @_m = :"finish__#{ @_name_symbol }__by"
          @_sess = @_pbc.real_store_.internal_store_substrate
          yes = @_sess.respond_to? @_m
        end

        if yes
          ___knownness_via_customized_operation_dependency
        else
          __knownness_via_non_customized_operation_dependency
        end
      end

      def ___knownness_via_customized_operation_dependency

        _business_result_x = @_sess.send @_m, @_bc.receiver

        # (maybe this succeeded, maybe it failed. for now we are indifferent?)

        Common_::KnownKnown[ _business_result_x ]
      end

      def __knownness_via_non_customized_operation_dependency

        _p = @_procure_bound_call.on_unavailable_kn_.value

        ok_x = @_bc.receiver.send @_bc.method_name, * @_bc.args, & _p
        if ok_x

          if @_procure_bound_call.did_emit_
            self._WEEE  # maybe emit the events back into the bc block # #todo
          end

          Common_::KnownKnown[ ok_x ]
        else

          _ = @_procure_bound_call.release_reasoning_

          # (when the above fails, design something. hopefully all failure
          #  of dependee operations will have client-provided emission.)

          Common_::KnownUnknown.via_reasoning _
        end
      end

      def _unavailability_proc

        _nt = remove_instance_variable :@_node_reference

        @_fo = @_modality_frame.build_formal_operation_via_node_reference_ _nt

        p = @_fo.unavailability_proc
        if p
          p[ @_fo ]
        end
      end

      def _init_procure_bound_call
        @_procure_bound_call = @_pbc.begin_recursion__ @_fo
        NIL_
      end
    end

    class State__  # as described in [#030]

      def initialize evl

        # (in our experience, there should be no need to add the assocation
        # to the construction or constituency of this class because the evl
        # is a known unknown that has a reason object array each of whose
        # reason has a proc to build an event which has the selection stack
        # already in it whew!)

        @__cached_evl = evl
      end

      def cached_evaluation_
        @__cached_evl
      end

      def in_progress
        false
      end
    end
  end
end
