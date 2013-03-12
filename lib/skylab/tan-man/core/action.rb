module Skylab::TanMan

  module Core::Action             # it is probably not prudent to make a
  end                             # modality-agnostic action base class!

  module Core::Action::ModuleMethods

    include Headless::Action::ModuleMethods # maybe one day dsl services

    include PubSub::Emitter::ModuleMethods # if descendents want to add to
                                  # the even graph or change the class, for e.g.

    def build parent              # hopefully only before [#018] bleeding,
                                  # this overrides a bleeding impl. to fit with
      new parent                  # our preferred sub-client pattern
    end
  end

  module Core::Action::InstanceMethods

    include Headless::Action::InstanceMethods # per headless pattern

    extend PubSub::Emitter        # we want the methods it generates to be here
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
