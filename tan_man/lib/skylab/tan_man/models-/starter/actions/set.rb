module Skylab::TanMan

  module Models_::Starter

    class Actions::Set

      # -

        def definition

          _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_

          [
            :properties, _these,
            :required, :property, :starter_name,
          ]
        end

        def initialize
          @dry_run = false  # (or make it a parameter)
          extend Home_::Model_::CommonActionMethods
          init_action_ yield
        end

        def execute
          if __normalize_starter
            __write_starter_to_config
          end
        end

        # -- B

        def __write_starter_to_config
          with_mutable_workspace_ do
            __write_starter_to_workspace
          end
        end

        def __write_starter_to_workspace

          _path = remove_instance_variable( :@__normal_item ).path

          @_mutable_workspace_.write_digraph_asset_path_ _path, :starter, & _listener_
        end

        # -- A

        def __normalize_starter

          sct = Here_::Actions::Ls.lookup_starter_by_ do |o|
            o.starter_tail = remove_instance_variable :@starter_name
            o.microservice_invocation = @_microservice_invocation_
            o.listener = _listener_
          end

          if sct.did_find
            @__normal_item = sct.found_item ; ACHIEVED_
          end
        end

      # -

      Actions = nil

      # ==
      # ==
    end
  end
end
# #history-A: broke out of model file years after, full rewrite during [br] ween
