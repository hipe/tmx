module Skylab::Brazen

  class Models_::Workspace

  class Actions::Init < Home_::Action

    edit_entity_class(

      :desc, -> y do
        y << "init a #{ highlight '<workspace>' }"
        y << "this is the second line of the init description"
      end,

      :inflect, :noun, :lemma, :with_lemma, 'workspace',
        # the above gives us "inited workspace" instead of ".. *a* workspace"

      :promote_action,

      :flag, :property, :dry_run,

      :flag, :property, :verbose,

      :property_object, COMMON_PROPERTIES_[ :config_filename ],

      :required,
      :description, -> y do
        y << "the directory to init"
      end,
      :property, :path )

      # (the above order is the frontier for [#018] the ordering rationale)

    def produce_result

      bx = @argument_box

      @ws = silo_module.edit_entity @kernel, handle_event_selectively do | ent |
        ent.edit_with(
          :surrounding_path, bx.fetch( :path ),
          :config_filename, bx.fetch( :config_filename ) )
      end

      @ws and __via_workspace
    end

    def __via_workspace

      _prp = formal_properties.fetch :path
      _oes = __event_dispatcher

      _ok = @ws.init_workspace(
        :is_dry, @argument_box[ :dry_run ],
        :app_name, @kernel.app_name,
        :prop, _prp,
        & _oes )

      _ok and @ws  # experiment
    end

    def __event_dispatcher

      _ = Callback_::Event.produce_handle_event_selectively_through_methods
      _.bookends self, :init
    end

    def on_init_resource_not_found_via_channel i_a, & ev_p
      # when initting, the resource not being found is normal; so in those
      # cases we report (a neutral version of) the event IFF verbose
      if @argument_box[ :verbose ]
        maybe_send_event_via_channel i_a do
          ev_p[].with :ok, nil
        end
      end
      ACHIEVED_
    end

    def on_init_directory_already_has_config_file_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      UNABLE_
    end

    def on_init_start_directory_does_not_exist_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      UNABLE_
    end

    def on_init_start_directory_is_not_directory_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      UNABLE_
    end

    def on_init_found_is_not_file_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      UNABLE_
    end

    def on_init_creating_directory_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      nil
    end

    def on_init_before_probably_creating_new_file_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      NIL_
    end

    def on_init_success_via_channel i_a, & ev_p
      maybe_send_event_via_channel i_a, & ev_p
      UNABLE_
    end
  end
  end
end
