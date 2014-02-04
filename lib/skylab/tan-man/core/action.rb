module Skylab::TanMan

  module Core::Action             # it is probably not prudent to make a
  end                             # modality-agnostic action base class!

  module Core::Action::ModuleMethods

    include Headless::Action::Anchored_Name_MMs

    Callback[ self, :include_emitter_module_methods ]  # if descedents want to add to
                                  # the even graph or change the class, for e.g.

    def build parent              # hopefully only before [#018] bleeding,
                                  # this overrides a bleeding impl. to fit with
      new parent                  # our preferred sub-client pattern
    end
  end

  module Core::Action::InstanceMethods

    Callback[ self, :employ_DSL_for_emitter ]  # we want its generated methods here
                                  # we want its emit() def to trump above

    include Core::SubClient::InstanceMethods # per headless, this does a lot

                                  # the below event graph is used and
                                  # must be honored accross modalities.

    emits Bleeding::EVENT_GRAPH.merge(           call_to_action: :all,
                                                           info: :all,
                                                  no_config_dir: :error,
                                                        payload: :all,
                                                           skip: :info )
  end
end
