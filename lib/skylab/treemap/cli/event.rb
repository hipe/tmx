module Skylab::Treemap

  module CLI::Event

    LINE_STREAMS = [ :payload_line, :info_line ]

    CANON_STREAMS = LINE_STREAMS + [ :info, :error, :help ]

  end

  class CLI::Event::Annotated_Text < Core::Event::Annotated::Text
  end

  CLI::Event::FACTORY = -> do
    factory = Core::Event::FACTORY.dupe
    factory.add_physical_factory :textual, CLI::Event::Annotated_Text
    factory
  end.call
end
