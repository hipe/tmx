module Skylab::TanMan

  module API

    module Actions::Graph::Remote

      class Add < API::Action

        emits event_structure: :all

        extend API::Action::Attribute_Adapter

        attribute :node_names, default: nil
        attribute :script, required: true
        attribute :verbose, default: nil

      private

        def execute
          begin
            controllers.config.ready? or break
            cnt = collections.dot_file.currently_using or break
            _attr_a = [ ( :node_names if @node_names ) ].compact
            r = cnt.add_remote_notify :remote_type, :script, :script, @script,
              :attribute_a, _attr_a, :be_verbose, @verbose
          end while nil
          r
        end
      end
    end
  end
end
