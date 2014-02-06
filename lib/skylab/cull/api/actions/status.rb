module Skylab::Cull

  class API::Actions::Status < API::Action

    params [ :do_list_file, :arity, :zero_or_one, :argument_arity, :zero ]

    services :configs, [ :pth, :ivar ]

    listeners_digraph yes: :structural, no: :structural,
      hard_yes: :payload_lines

    event_factory Callback::Event::Factory::Structural.new(
      3, nil, API::Events_ ).method( :event )
      # #todo the above is good but can probably be cleaned up

    def execute
      configs.find_nearest_config_file_path nil, nil,
        method( :with_yes ), method( :with_no )
    end

  private

    def with_yes pn
      if @do_list_file
        hard_yes payload_lines: [ "#{ @pth[ pn ] }" ]
      else
        yes pathname: pn,
            message_proc: -> { "active config file is: #{ @pth[ pn ] }" }
      end
      true
    end

    def with_no num, from_pn
      no num: num, from_pn: from_pn,
        message_proc: -> do
          "no cull config file found in #{ @pth[ from_pn ] } or #{
          }#{ num } levels up."
        end
      false
    end
  end
end
