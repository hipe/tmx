module Skylab::Cull

  class Models_::Survey

    class Models__::Upstream

      def initialize survey, & oes_p
        @survey = survey
        @on_event_selectively = oes_p
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

        @_top_entity = Models_::Upstream.edit_entity @survey.to_kernel, @on_event_selectively do | edit |

          edit.reference_path ::File.join( @survey.path, FILENAME_ )
          edit.mutable_arg_box bx

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
        ok = @_top_entity.marshal_dump_for_survey @survey
        ok &&= @survey.persist_value_for_name_symbol_ ok, :upstream
        ok && __maybe_send_set_event
      end

      def __maybe_send_set_event
        @on_event_selectively.call :info, :set_upstream do
          @_top_entity.to_event
        end
        ACHIEVED_
      end

      def delete
        @survey.destroy_all_persistent_nodes_for_name_symbol_ :upstream
      end
    end
  end
end
