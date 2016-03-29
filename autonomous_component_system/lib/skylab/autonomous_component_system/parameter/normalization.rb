module Skylab::Autonomous_Component_System

  class Parameter

    class Normalization  # [#028] (and see open tag below)

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
        :bespoke_stream_once,  # see [#027]#bespoke
        :expanse_stream_once,  # see [#027]#expanse
        :parameter_store,  # wrap e.g a session object or argument array
        :parameter_value_source,
      )

      def execute

        if @parameter_value_source.is_not_known_to_be_empty_
          # adhere to [#]:#API-point-A - do bespokes IFF etc
          ___interpret_any_bespokes
        end

        __common_normalize
      end

      def ___interpret_any_bespokes  # see [#]:#"head parse"

        _st = remove_instance_variable( :@bespoke_stream_once ).call
        _bx = _box_via_stream _st

        cont = @parameter_value_source.to_controller_against__ _bx

        st = cont.consuming_formal_parameter_stream
        begin
          par = st.gets
          par or break

          # reminder: we do *not* `ACS_::Interpretation::Build_value` here.

          _x = cont.current_argument_stream.gets_one  # ..

          @parameter_store.accept_parameter_value _x, par

          redo
        end while nil

        NIL_
      end

      def __common_normalize

        # • implement the [#]:#Algorithm
        # • honor [#]:#API-point-B: evaluate every formal in formal order
        # • generalize to work with [#ze-027]:#C3
        # • partially duplicate something in [fi] #open [#021]

        Require_field_library_[]

        miss_a = nil
        add_mixed_failure_object = -> x_o do
          ( miss_a ||= [] ).push x_o
        end

        fo_st = remove_instance_variable( :@expanse_stream_once ).call

        rdr_p = @parameter_store.evaluation_proc
        rdr_p or self._WHERE

        begin
          f = fo_st.gets
          f or break

          evl = rdr_p[ f ]  # honor the above mentioned API point.
          if evl.is_effectively_known
            redo
          end

          # assume it is not effectively known. it must be either known
          # unknown or known to be nil (right?). IFF the former it may have
          # some "reasoning" attached to it. if it does then this constitutes
          # *the* implementation of [#fi-036]#"Storypoint-2". otherwise munge
          # these two cases with one behavior.

          if evl.is_known_known
            evl.value_x.nil? or self._SANITY
            reasoning_x = nil
          else
            reasoning_x = evl.reasoning
          end

          if reasoning_x

            if Field_::Is_required[ f ]
              add_mixed_failure_object[ reasoning_x ]
              redo
            end

            # when reasons were given but the field is not required:

            self._COVER_ME_design_me_read_this  # ..what we do here might
            # should depend on the category of failure. if merely it couldn't
            # meet its dependencies (however no executions failed), then we
            # might want to skip. on the other hand, if executions failed
            # (somewhere), then we might want to express and behave around
            # the failure. this is exactly [#ze-027]#C3.  #open [#033].
          end

          # even if errors have occurred prior, we go through with it

          if Field_::Has_default[ f ]
            x = f.default_proc.call
            @parameter_store.accept_parameter_value x, f
          else
            x = nil
          end

          if x.nil? && Field_::Is_required[ f ]
            add_mixed_failure_object[ f ]
          end

          redo
        end while nil

        if miss_a
          ___when_failures_and_or_missing_requireds miss_a
        else
          ACHIEVED_
        end
      end

      def ___when_failures_and_or_missing_requireds miss_a

        ev = Field_::Events::Missing.new_with(
          :reasons, miss_a,
          :selection_stack, @selection_stack,
          :lemma, :parameter,
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
end
