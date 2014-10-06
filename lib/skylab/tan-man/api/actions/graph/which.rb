module Skylab::TanMan
  class API::Actions::Graph::Which < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = []

  private

    def execute
      res = nil
      begin
        col = collections.dot_file
        b = col.ready? -> o do
          if :no_config_dir == o.stream_name
            info "#{ o.message } - #{ o.dirname }"
            emit :call_to_action, template: "try {{action}} to create it",
                              action_class: API::Actions::Init # #ref [#059]
          else
            info o.message
            res = false # meh
          end
        end,
        -> no_param do
          info "there is no #{ lbl no_param } value in the config"
          emit :call_to_action, template: 'use {{action}} to create one',
                            action_class: API::Actions::Graph::Use #ref [#059]
        end,
        -> no_file do
          info "dotfile does not exist: #{ escape_path no_file }"
          emit :call_to_action, template: 'use {{action}} to create it',
                            action_class: API::Actions::Graph::Use #ref [#059]
        end
        b or break
        cnt = collections.dot_file.currently_using or break
        config_param = Models::DotFile::Collection._USE_the_entity_node_identifier_maybe
        payload "#{ lbl config_param } (exists): #{ escape_path cnt.pathname }"
        res = true
      end while nil
      res
    end

    attr_reader :verbose                       # compat
  end
end
