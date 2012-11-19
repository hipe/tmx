module Skylab::TanMan

  module Core::Action
  end

  module Core::Action::ModuleMethods
    include PubSub::Emitter::ModuleMethods

  end

  module Core::Action::InstanceMethods
    extend PubSub::Emitter        # we want the methods it generates to be here

    emits Bleeding::EVENT_GRAPH.merge( # this is a graph used in multiple
      info: :all, out: :all, no_config_dir: :error, skip: :info # modalities
    )

    event_class Core::Event       # sure why not

  protected

    def add_invalid_reason mixed
      (@invalid_reasons ||= []).push mixed
    end

    def root_runtime # to be re-evaluated at [#034]
      if parent
        parent.root_runtime
      else
        self
      end
    end
  end
end
