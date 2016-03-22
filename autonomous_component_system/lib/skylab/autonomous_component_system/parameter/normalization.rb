module Skylab::Autonomous_Component_System

  class Parameter

    class Normalization  # [#028]

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize ss

        @on_missing_required = nil
        @selection_stack = ss  # used to enrich emissions & for receiver
      end

      attr_writer(
        :bespoke_stream_once,  # see [#027]#bespoke
        :expanse_stream_once,  # see [#027]#expanse
        :on_missing_required,  # emission handler. if not set raises event ex.
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

      def __common_normalize  # implement [#]:#API-point-B

        Require_field_library_[]

        miss_a = nil

        fo_st = remove_instance_variable( :@expanse_stream_once ).call

        rdr_p = @parameter_store.value_reader_proc

        begin
          f = fo_st.gets
          f or break

          x = rdr_p.call f do
            NIL_
          end

          if x.nil? && Field_::Has_default[ f ]
            x = f.default_proc.call
            @parameter_store.accept_parameter_value x, f
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
          :miss_a, miss_a,
          :selection_stack, @selection_stack,
          :lemma, :parameter,
        )

        oes_p = @on_missing_required

        if oes_p
          oes_p.call :error, :missing_required_properties do
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
