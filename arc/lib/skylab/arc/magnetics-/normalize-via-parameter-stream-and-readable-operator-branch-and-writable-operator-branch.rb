module Skylab::Arc

  class Magnetics_::Normalize_via_ParameterStream_and_ReadableOperatorBranch_and_WritableOperatorBranch

      # 1x. [ac] only. [#028] (and see open tag below)

      # #open [#008.D] modernize interface (or don't)

      # :[#fi-037.5.L].

      # (we're calling this the fourth implementation of [#ta-005] pathfinding
      # although that's a bit of a stretch.)

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize ss

        @on_missing_required = nil
        @selection_stack = ss  # used to enrich emissions & for receiver
      end

      def on_reasons= x
        @on_missing_required = x  # emission handler. if not set raises event ex.
      end

      attr_writer(
        :association_index_memoized_by,  # (was once "see [#027]#expanes" )
        :parameter_store,  # wrap e.g a session object or argument array
        :parameter_value_source,
        :PVS_parameter_stream_once,  # see [#028]#"Head parse"
      )

      def execute

        if ! @parameter_value_source.is_known_to_be_empty
          # adhere to [#]:#API-point-A - do these IFF etc
          ___interpret_non_empty_PVS
        end

        __common_normalize
      end

      def ___interpret_non_empty_PVS  # see [#]:#"Head parse"

        _st = remove_instance_variable( :@PVS_parameter_stream_once ).call
        _bx = _box_via_stream _st

        cont = @parameter_value_source.to_controller_against _bx

        st = cont.consuming_formal_parameter_stream
        begin
          par = st.gets
          par or break

          # reminder: we do *not* `Home_::Magnetics::QualifiedComponent_via_Value_and_Association` here.

          _x = cont.current_argument_scanner.gets_one  # ..

          @parameter_store.accept_parameter_value _x, par

          redo
        end while nil

        NIL_
      end

      def __common_normalize

        # :[#fi-037.5.L]

        # • implement the [#]:#Algorithm
        # • honor [#]:#API-point-B: evaluate every formal in formal order
        # • generalize to work with [#ze-027]:#Operational-dependencies
        # • partially duplicate something in [fi] #open [#021]

        Require_fields_lib_[]

        miss_a = nil
        add_mixed_failure_object = -> x_o do
          ( miss_a ||= [] ).push x_o
        end

        ai = remove_instance_variable( :@association_index_memoized_by ).call
        asc_st = ai.to_native_association_stream
        is_req = ai.to_is_required_by
        ai = nil

        rdr_p = @parameter_store.evaluation_proc
        rdr_p or self._WHERE

        begin
          asc = asc_st.gets
          asc || break

          sym = asc.singplur_category_of_association
          if sym && :singular_of == sym
            # currently we never use the singular side for storage.
            redo
          end

          evl = rdr_p[ asc ]  # honor the above mentioned API point.
          if evl.is_effectively_known
            redo
          end

          # assume it is not effectively known. it must be either known
          # unknown or known to be nil (right?). IFF the former it may have
          # some "reasoning" attached to it. if it does then this constitutes
          # *the* implementation of [#fi-036.5] "reasoning". otherwise munge
          # these two cases with one behavior.

          if evl.is_known_known
            evl.value.nil? or self._SANITY
            reasoning_x = nil
          else
            reasoning_x = evl.reasoning
          end

          if reasoning_x

            if is_req[ asc ]
              add_mixed_failure_object[ reasoning_x ]
              redo
            end

            # when reasons were given but the field is not required:

            self._COVER_ME_design_me_read_this  # ..what we do here might
            # should depend on the category of failure. if merely it couldn't
            # meet its dependencies (however no executions failed), then we
            # might want to skip. on the other hand, if executions failed
            # (somewhere), then we might want to express and behave around
            # the failure. this is exactly [#ze-027]#Operational-dependencies.  #open [#033].
          end

          # even if errors have occurred prior, we go through with it

          if Field_::Has_default[ asc ]
            x = asc.default_proc.call
            @parameter_store.accept_parameter_value x, asc
          else
            x = nil
          end

          if x.nil? && is_req[ asc ]
            add_mixed_failure_object[ asc ]
          end

          redo
        end while above

        if miss_a
          ___when_failures_and_or_missing_requireds miss_a
        else
          ACHIEVED_
        end
      end

      def ___when_failures_and_or_missing_requireds miss_a

        ev = Field_::Events::Missing.with(
          :reasons, miss_a,
          :selection_stack, @selection_stack,
          :noun_lemma, :parameter,
          :exception_class_by, -> { Home_::MissingRequiredParameters },
        )

        oes_p = @on_missing_required

        if oes_p
          oes_p.call :error, :missing_required_parameters do
            ev
          end
          UNABLE_
        else
          raise ev.to_exception
        end
      end  # (is mentor of #here-1)

      # -- support

      def _box_via_stream st
        st.flush_to_box_keyed_to_method :name_symbol
      end
  end
end
