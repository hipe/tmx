module Skylab::Brazen

  class Models_::Workspace

  class Actions::Status < Brazen_::Model_::Action

    Brazen_::Model_::Entity.call self do

      o :desc, -> y do
        y << "get status of a workspace"
      end

      o :inflect, :verb, 'determine'

      o :promote_action

      o :after, :init

      o :environment, :non_negative_integer,
        :description, -> y do
          y << "how far up do we look?"
        end,
        :property, :max_num_dirs

      o :flag, :property, :verbose

      o :default, '.',
        :description, "the location of the workspace",
        :description, -> y do
          y << "it's #{ highlight 'really' } neat"
        end,
        :required, :property, :path

    end

    def produce_any_result

      bx = @argument_box

      model_class.merge_workspace_resolution_properties_into_via bx, self

      _oes_p = event_lib.
        produce_handle_event_selectively_through_methods.
          bookends self, :status do | * i_a, & ev_p |
        maybe_send_event_via_channel i_a, & ev_p
      end

      @ws = model_class.edit_entity @kernel, handle_event_selectively do |o|

        o.with_argument_box bx

        o.with(
          :prop, self.class.properties.fetch( :path ),
          :on_event_selectively, _oes_p )
      end
      @ws and work
    end

    def work
      pn = @ws.execute
      pn and when_pn
    end

    def when_pn
      maybe_send_event :info, :resource_exists do
        build_OK_event_with :resource_exists,
          :pathname, @ws.pn, :is_completion, true
      end
    end

    def on_status_resource_not_found_via_channel i_a, & ev_p

      # in a status inquiry, not finding the resource is not not OK. we chose
      # to make it OK. however because of what are perhaps confused semantics
      # if we result in true-ish from this method is it treated as a path for
      # the resource. hence we result in nil.

      maybe_send_event_via_channel i_a do
        ev_p[].dup_with :ok, ACHIEVED_
      end
      nil
    end
  end
  end
end
