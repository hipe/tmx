module Skylab::SubTree

  class CLI::Action

    SubTree::Core::Action::Anchored_Normal_Name_[ self ]

    ACTIONS_ANCHOR_MODULE = SubTree::CLI::Actions

  private

    def corresponding_api_action_class
      i_a = anchored_normal_name
      1 == i_a.length or self._DO_ME
      _name = Name_.from_variegated_symbol i_a.last
      SubTree::API::Actions.const_get _name.as_const, false
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
