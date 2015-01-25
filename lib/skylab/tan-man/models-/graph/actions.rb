module Skylab::TanMan

  class Models_::Graph

    Entity_.call self,

        :persist_to, :graph,

        :required, :property, :digraph_path

    Actions = make_action_making_actions_module

    module Actions

      Use = make_action_class :Create

      class Use

        Entity_.call self,

          :properties,
            :starter,
            :created_on

        use_workspace_as_datastore_controller

        def template_value i
          send :"#{ i }_template_value"
        end

        def created_on_timestamp_string_template_value
          if @argument_box.has_name :created_on
            @argument_box.fetch :created_on
          else
            ::Time.now.utc.to_s
          end
        end

        def _ws
          if instance_variable_defined? :@preconditions  # #experimental
            @preconditions.fetch :workspace
          end
        end
      end
    end

    def natural_key_string
      @property_box.fetch :digraph_path
    end

    def to_normalized_actual_property_scan_for_persist

      bx = Callback_::Box.new

      bx.add Brazen_::NAME_, ::Pathname.new(
        @property_box.fetch :digraph_path
      ).relative_path_from(
        @datastore.datastore_controller.wsdpn
      ).to_path

      bx.to_pair_stream
    end

    class Collection_Controller__ < Collection_Controller_

      use_workspace_as_dsc

      def persist_entity ent, & oes_p

        _is_dry = ent.any_parameter_value :dry_run

        @dsc ||= datastore_controller

        _ok = Graph_::Actors__::Touch[ _is_dry, @action, ent, @dsc, @kernel, & oes_p ]

        _ok and super
      end
    end

    Autoloader_[ Actors__ = ::Module.new ]

    Graph_ = self
  end
end
