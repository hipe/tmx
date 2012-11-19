module Skylab::TanMan

  module Core::Action
  end


  module Core::Action::ModuleMethods
    include PubSub::Emitter::ModuleMethods # if descendents want to add to
  end                             # the even graph or change the class, for e.g.


  module Core::Action::InstanceMethods
    extend PubSub::Emitter        # we want the methods it generates to be here

    emits Bleeding::EVENT_GRAPH.merge( # this is a graph used in multiple
      info: :all, out: :all, no_config_dir: :error, skip: :info # modalities
    )

    event_class Core::Event       # (altho descendents may change it)
  end
end
