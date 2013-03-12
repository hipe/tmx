module Skylab::Treemap

  module API::Event
  end

  module API::Event::Annotated
    # we had to do some late-binding to preserve how api wants to do it
    def self.event arg1, stream_name, payload_x
      if payload_x.respond_to? :key?
        API::Event::Annotated::Struct_Presumtuous.event(
          arg1, stream_name, payload_x )
      else
        API::Event::Annotated::Text.event arg1, stream_name, payload_x
      end
    end
  end

  class API::Event::Annotated::Text < Core::Event::Annotated::Text
  end

  class API::Event::Annotated::Struct_Presumtuous < Core::Event::Annotated
    # (careful, this module gets filled with dynamic generated structs)

    def self.event a, b, c
      @structure_factory.event a, b, c
    end

    def self.structure_factory num
      already = true
      @structure_factory ||= begin
        already = false
        PubSub::Event::Factory::Structural.new 3, self, self
      end
      already and raise ::RuntimeError, "factory already exists"
      nil
    end

    structure_factory 3

    def has_metadata
      true
    end

    def has_metadata_element name
      self.class.members.include? name
    end

    def initialize action_sheet, stream_name
      # (at this point your ivars are already set with rich, complex metadata)
      super action_sheet
    end
  end

  API::Event::FACTORY = -> do
    factory = Core::Event::FACTORY.dupe
    factory.add_physical_factory :textual, API::Event::Annotated::Text
    factory.add_physical_factory :annotated, API::Event::Annotated
    factory.change_logical_factory :error, :annotated
    factory.change_logical_factory :info, :annotated
    factory.add_logical_factory :pdf, :annotated
    factory
  end.call
end
