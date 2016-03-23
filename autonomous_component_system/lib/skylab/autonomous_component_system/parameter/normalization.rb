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

        if @parameter_value_source.is_not_known_to_be_empty__
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

        # implement the [#]:#Algorithm
        # implement [#]:#API-point-B - (evaluate every formal in formal order)
        # generalize to work with [#ze-027]:#Crazytimes.3.A
        # this partially duplicates something in [fi] #open [#021]

        Require_field_library_[]

        miss_a = nil

        fo_st = remove_instance_variable( :@expanse_stream_once ).call

        rdr_p = @parameter_store.evaluation_proc
        rdr_p or self._WHERE

        begin
          f = fo_st.gets
          f or break

          evl = rdr_p[ f ]
          if evl.is_effectively_known
            redo
          end

          # now it's either known to be nil or known unknown

          if ! evl.is_known_known
            # if it was known unknown for some *reason* (like a failure
            # to establish dependencies), then this:
            rsn = evl.reason_object
            if rsn
              ( miss_a ||= [] ).push rsn
              redo
            end
          end

          # even if errors have occurred prior, we go through with it

          if Field_::Has_default[ f ]
            x = f.default_proc.call
            @parameter_store.accept_parameter_value x, f
          else
            x = nil
          end

          if x.nil? && Field_::Is_required[ f ]
            ( miss_a ||= [] ).push f
          end

          redo
        end while nil

        if miss_a
          ___when_missing_requireds miss_a
        else
          ACHIEVED_
        end
      end

      def ___when_missing_requireds miss_a

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
