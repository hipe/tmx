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


    emits Bleeding::EVENT_GRAPH.merge( # this is a graph used in multiple
      info: :all, payload: :all, no_config_dir: :error, skip: :info # modalities
    )

    event_class Core::Event       # descendents may change this

  protected

    def config # #pattern #016 - action instances make controllers
      @config ||= TanMan::Models::Config::Controller.new self
    end

    def dot_files # #pattern #016
      @dot_files ||=
        TanMan::Models::DotFiles::Controller.new request_client, config
    end
  end
end
