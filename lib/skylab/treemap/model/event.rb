module Skylab::Treemap

  module Model::Event
  end

  class Model::Event::Annotated <
    Treemap::API::Event::Annotated::Struct_Presumtuous

    structure_factory 3  # sanity limit on number of structs

  end

  module Model::Event::Mapping
    extend MetaHell::Boxxy
    Annotated = Model::Event::Annotated
    Text = PubSub::Event::Factory::Datapoint
  end

  Model::Event::FACTORY = PubSub::Event::Factory::Isomorphic.new(
    Model::Event::Mapping )
end
