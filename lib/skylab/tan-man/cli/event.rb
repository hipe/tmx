module Skylab::TanMan

  # Some of the below might get overhauled near [#076] whenever we
  # feel like it..it is based around a very build-out event mesh
  # that was written right before the great `event factory`
  # epiphany and overhaul of 1909.

  module CLI::Event
  end

  class CLI::Event::Messagular < PubSub::Event::Unified  # `touched?`

    class << self
      alias_method :event, :new
    end

    include TanMan::Core::Event::LingualMethods

    def initialize a, b, c=nil
      super a, b
      init_lingual c if c
    end
  end

  class CLI::Event::Structic < PubSub::Event::Unified

    # (used as dynamic namespace too)

    include Core::Event::LingualMethods
  end

  module CLI::Event::Mappings

    String = CLI::Event::Messagular

    Hash = PubSub::Event::Factory::Structural.new 10,
      CLI::Event::Structic, CLI::Event::Structic  # base kls & box module

  end

  CLI::Event::Factory = PubSub::Event::Factory::Late.new( CLI::Event::Mappings )
end
