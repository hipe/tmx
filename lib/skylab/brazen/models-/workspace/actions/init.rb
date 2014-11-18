module Skylab::Brazen

  class Models_::Workspace

  class Actions::Init < Brazen_::Model_::Action

    Brazen_::Model_::Entity[ self, -> do

      o :desc, -> y do
        y << "init a #{ highlight '<workspace>' }"
        y << "this is the second line of the init description"
      end,

      :inflect, :noun, :lemma, :with_lemma, 'workspace',

      :is_promoted,

      :flag, :property, :dry_run,

      :flag, :property, :verbose,

      :default, '.',
      :description, -> y do
        y << "the directory to init"
      end,
      :property, :path  # even though not alphabetical, leave at end

    end ]

    def produce_any_result

      bx = @argument_box

      model_class.merge_workspace_resolution_properties_into_via bx, self

      bx.replace :max_num_dirs, 1

      @prop = self.class.properties.fetch :path
      @ws = model_class.edited self, @kernel do |o|
        o.with_argument_box bx
        o.with :prop, @prop,
          :app_name, @event_receiver.app_name,
          :channel, :init
      end
      @ws.error_count.zero? and work
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
      send_not_OK_event_with :directory_already_has_config_file,
        :pathname, @ws.pn, :prop, @prop
      nil
    end

    def receive_init_resource_not_found ev
      if any_argument_value :verbose
        _ev = ev.dup_with :ok, ACHIEVED_
        receive_event _ev
      end
      @ok = true ; CONTINUE_
    end

    def receive_init_start_directory_does_not_exist ev
      receive_event ev ; @ok = false
    end

    def receive_init_start_directory_is_not_directory ev
      receive_event ev ; @ok = false
    end

    def receive_init_found_is_not_file ev
      receive_event ev ; @ok = false
    end

    def flush
      @ws.any_result_for_flush_for_init
    end

  end
  end
end
