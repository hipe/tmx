module Skylab::Brazen

  class Models_::Workspace

  class Actions::Status < Brazen_::Action

    edit_entity_class(

      :desc, -> y do
        y << "get status of a workspace"
      end,

      :inflect, :verb, 'determine',

      :promote_action,

      :after, :init,

      :description, -> y do
        prp = @current_property
        if prp.has_primitive_default
          _dflt = " (default: #{ ick prp.primitive_default_value })"
        end
        y << "how far up do we look?#{ _dflt }"
      end,

      :non_negative_integer,
      :default, '1',
      :property, :max_num_dirs,

      :flag, :property, :verbose,

      :property_object, COMMON_PROPERTIES_[ :config_filename ],

      :description, "the location of the workspace",
      :description, -> y do
        y << "it's #{ highlight 'really' } neat"
      end,
      :required, :property, :path )

    def produce_result

      @ws = model_class.edit_entity @kernel, handle_event_selectively do |o|
        bx = @argument_box
        o.edit_with(
          :surrounding_path, bx.fetch( :path ),
          :config_filename, bx.fetch( :config_filename ) )
      end

      @ws and __via_workspace
    end

    def __via_workspace

      _prp = formal_properties.fetch :path
      _oes = __event_dispatcher

      _ok = @ws.resolve_nearest_existent_surrounding_path(
        @argument_box.fetch( :max_num_dirs ),
        :prop, _prp,
        & _oes )

      if _ok
        __when_found
      else
        @user_result
      end
    end

    def __event_dispatcher

      _ = Callback_::Event.produce_handle_event_selectively_through_methods
      _.bookends self, :status do | * i_a, & ev_p |

        @user_result = maybe_send_event_via_channel i_a, & ev_p
        UNABLE_
      end
    end

    def __when_found
      maybe_send_event :info, :resource_exists do
        build_OK_event_with :resource_exists,
            :config_path, @ws.existent_config_path,
            :is_completion, true do | y, o |

          y << "resource exists - #{ pth o.config_path }"
        end
      end
      # the result is up to the user
    end

    def on_status_resource_not_found_via_channel i_a, & ev_p

      # in a status inquiry, not finding the resource is not not OK. we chose
      # to make it OK. however because of what are perhaps confused semantics
      # if we result in true-ish from this method is it treated as a path for
      # the resource. hence we result in nil.

      @user_result = maybe_send_event_via_channel i_a do
        ev_p[].new_with :ok, ACHIEVED_
      end

      UNABLE_
    end
  end
  end
end
