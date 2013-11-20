module Skylab::SubTree

  class CLI::Action

    SubTree::Core::Action::Anchored_Normal_Name_[ self ]

    ACTIONS_ANCHOR_MODULE = SubTree::CLI::Actions

  private

    def corresponding_api_action_class
      SubTree::API::Actions.const_fetch anchored_normal_name
    end

    def emit_from_parent stream_i, message_x
      if message_x.respond_to? :render_with
        message_x = message_x.render_with some_expression_agent
      end
      @cli_client_emit_p[ stream_i, message_x ]
      nil
    end
  end
end
