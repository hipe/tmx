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

      class List < API::Action

        emits event_structure: :all

        def set! _
          _ ? never : true
        end

        attr_reader :verbose

      private

        def execute
          begin
            controllers.config.ready? or break
            cnt = collections.dot_file.currently_using or break
            r = cnt.get_remote_scanner
          end while nil
          r
        end
      end

      class Remove < API::Action

        extend API::Action::Attribute_Adapter

        attribute :dry_run, default: nil
        attribute :locator, required: true

        attr_accessor :verbose

      private

        def execute
          begin
            controllers.config.ready? or break
            cnt = collections.dot_file.currently_using or break
            r = cnt.remove_remote_with_dry_run_and_locator @dry_run, @locator
          end while nil
          r
        end
      end
    end
  end
end
