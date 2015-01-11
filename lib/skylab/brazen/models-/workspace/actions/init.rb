module Skylab::Brazen

  class Models_::Workspace

  class Actions::Init < Brazen_::Model_::Action

    Brazen_::Model_::Entity.call self do

      o :desc, -> y do
        y << "init a #{ highlight '<workspace>' }"
        y << "this is the second line of the init description"
      end,

      :inflect, :noun, :lemma, :with_lemma, 'workspace',

      :promote_action,

      :flag, :property, :dry_run,

      :flag, :property, :verbose,

      :default, '.',  # #open [#083] - this will not stay here
      :description, -> y do
        y << "the directory to init"
      end,
      :property, :path  # even though not alphabetical, leave at end

    end

    def produce_any_result

      bx = @argument_box

      model_class.merge_workspace_resolution_properties_into_via bx, self

      bx.replace :max_num_dirs, 1

      _oes_p = event_lib.
        produce_handle_event_selectively_through_methods.
          bookends self, :init

      @prop = self.class.properties.fetch :path
      @ws = model_class.edit_entity @kernel, handle_event_selectively do |o|
        o.argument_box bx
        o.where :prop, @prop,
          :app_name, @kernel.app_name,
          :on_event_selectively, _oes_p
      end
      @ws and work
    end

    def work
      pn = @ws.execute
      if pn
        when_already
      elsif @ok
        flush
      end
    end

    def when_already
      maybe_send_event :error, :directory_already_has_config_file do
        build_not_OK_event_with :directory_already_has_config_file,
          :pathname, @ws.pn, :prop, @prop
      end
      nil
    end

    def on_init_resource_not_found_via_channel i_a, & ev_p
      # when initting, the resource not being found is normal; so in those
      # cases we report (a neutral version of) the event IFF verbose
      @ok = true
      if any_argument_value :verbose
        maybe_send_event_via_channel i_a do
          ev_p[].dup_with :ok, nil
        end
      end
      CONTINUE_
    end

    def on_init_start_directory_does_not_exist_via_channel i_a, & ev_p
      @ok = false
      maybe_send_event_via_channel i_a, & ev_p
    end

    def on_init_start_directory_is_not_directory_via_channel i_a, & ev_p
      @ok = false
      maybe_send_event_via_channel i_a, & ev_p
    end

    def on_init_found_is_not_file_via_channel i_a, & ev_p
      @ok = false
      maybe_send_event_via_channel i_a, & ev_p
    end

    def on_init_success_via_channel i_a, & ev_p
      @ok = true
      maybe_send_event_via_channel i_a, & ev_p
    end

    def flush
      @ws.any_result_for_flush_for_init
    end

  end
  end
end
