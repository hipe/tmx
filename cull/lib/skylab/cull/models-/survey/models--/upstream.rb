module Skylab::Cull

  class Models_::Survey

    module Models__::Upstream

      if false
      def initialize survey, & oes_p
        @survey = survey
        @_emit = oes_p

        cfg = survey.config_for_read_
        if cfg
          sect = cfg.sections.lookup_softly :upstream
          sect and __unmarshal sect
        end
      end

      def __unmarshal sect

        @___ubox___ = Common_::Box.new

        if s = sect.subsection_string
          __unmarshal_id s
        end

        st = sect.assignments.to_stream_of_assignments

        while ast = st.gets
          m = :"___unmarshal_#{ ast.external_normal_name_symbol }_property"
          if respond_to? m
            send m, ast.value
          end
        end

        bx = @___ubox___ ; @___ubox___ = nil

        # the below is just to keep things rigid but we might back it off later

        if ! bx.has_key :table_number
          bx.add :table_number, nil
        end

        if ! bx.has_key :upstream_adapter
          bx.add :upstream_adapter, nil
        end

        if bx.length.nonzero?
          @_top_entity = Models_::Upstream.edit_entity @survey.kernel, @_emit do | edit |
            edit.derelativizer @survey
            edit.mutable_value_box bx
          end
        end

        nil
      end

      def __unmarshal_id s
        @___ubox___.add :upstream, s
        nil
      end

      def ___unmarshal_upstream_adapter_property s
        @___ubox___.add :upstream_adapter, s
        nil
      end

      def ___unmarshal_table_number_property d
        @___ubox___.add :table_number, d
        nil
      end

      def set arg, bx
        if arg.value.length.zero?
          _unset
        else
          _set arg, bx
        end
      end

      def _unset
        @survey.add_to_persistence_script_(
          :call_on_associated_entity_,
          :upstream,
          :delete )
        ACHIEVED_
      end

      def delete
        @survey.destroy_all_persistent_nodes_for_name_symbol_ :upstream
      end

      def entity_stream_at_some_table_number d  # is assumed fixnum
        @_top_entity.entity_stream_at_some_table_number d
      end

      def to_entity_stream
        @_top_entity.to_entity_stream
      end

      def to_entity_stream_stream
        @_top_entity.to_entity_stream_stream
      end
      end

      class WriteComponent_via_Component_and_Survey < Common_::Dyadic

        def initialize qc, survey, & p
          @upstream = qc.value
          @association = qc.association
          @survey = survey
          @listener = p
        end

        def execute
          if __write_to_survey
            __emit_event
            ACHIEVED_
          end
        end

        def __emit_event

          _ev = @upstream.to_descriptive_event  # #todo

          @listener.call :info, :set_upstream do
            _ev
          end

          NIL
        end

        def __write_to_survey

          _st = @upstream.to_persistable_primitive_name_value_pair_stream_recursive_ @survey

          _ok = @survey.write_component_via_primitives_by__ do |o|
            o.primitive_name_value_stream_recursive = _st
            o.association_name_symbol = @association.name_symbol
            o.listener = @listener
          end

          _ok  # hi. #todo
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end

      # ==

      # ==
      # ==
    end
  end
end
# #history-A.1: start to inject ween-off-[br] stuff
