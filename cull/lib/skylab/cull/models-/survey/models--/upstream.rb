module Skylab::Cull

  class Models_::Survey

    class Models__::Upstream

      def initialize survey, & oes_p
        @survey = survey
        @_emit = oes_p

        cfg = survey.config_for_read_
        if cfg
          sect = cfg.sections[ :upstream ]
          sect and __unmarshal sect
        end
      end

      def __unmarshal sect

        @___ubox___ = Common_::Box.new

        if s = sect.subsection_name_string
          __unmarshal_id s
        end

        st = sect.assignments.to_value_stream

        while ast = st.gets
          m = :"___unmarshal_#{ ast.external_normal_name_symbol }_property"
          if respond_to? m
            send m, ast.value_x
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
        if arg.value_x.length.zero?
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

      def _set arg, bx

        @_top_entity = Models_::Upstream.edit_entity @survey.kernel, @_emit do | edit |
          edit.derelativizer @survey
          edit.mutable_qualified_knownness_box bx
        end

        @_top_entity and via_edited_upstream
      end

      def via_edited_upstream

        @survey.add_to_persistence_script_(
          :call_on_associated_entity_,
          :upstream,
          :persist )

        ACHIEVED_
      end

      def persist
        bx = @_top_entity.to_mutable_marshal_box_for_survey @survey
        bx and __persist_via_box bx
      end

      def __persist_via_box bx
        x = bx.remove :upstream
        _ok = @survey.persist_box_and_value_for_name_symbol_ bx, x, :upstream
        _ok && __maybe_send_set_event
      end

      def __maybe_send_set_event
        @_emit.call :info, :set_upstream do
          @_top_entity.to_event
        end
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
  end
end
