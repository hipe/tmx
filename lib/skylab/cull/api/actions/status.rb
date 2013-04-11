module Skylab::Cull

  class API::Actions::Status < API::Action

    params  # none.

    emits yes: :structural, no: :structural

    event_factory PubSub::Event::Factory::Structural.new(
      2, nil, API::Events_ ).method( :event )

    def execute
      model( :configs ).find_nearest_config_file_path -> pathname do
        yes pathname: pathname,
          message_function: -> do
            "active config file is: #{ pth[ pathname ] }"
          end
        true
      end, -> num, from_pn do
        no num: num, from_pn: from_pn,
          message_function: -> do
            "no cull config file found in #{ pth[ from_pn ] } or #{
            }#{ num } levels up."
          end
        false
      end
    end
  end
end
