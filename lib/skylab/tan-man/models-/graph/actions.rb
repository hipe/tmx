module Skylab::TanMan

  class Models_::Graph

    Entity_.call self,

        :persist_to, :graph,

        :required, :property, :digraph_path

    class << self
      def action_class  # luckily we want all our (one) action(s) to be this way
        TanMan_::Model_::Document_Entity.action_class
      end
    end

    Actions = make_action_making_actions_module

    module Actions

      Use = make_action_class :Create do

        edit_entity_class(
          :preconditions, [ :workspace, :graph ],
          :properties,
            :starter,
            :created_on )
            # :reuse, Models_::Workspace.common_properties.array

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

    def to_pair_stream_for_persist

      bx = Callback_::Box.new

      bx.add Brazen_::NAME_, ::Pathname.new(
        @property_box.fetch :digraph_path
      ).relative_path_from(
        ::Pathname.new( @datastore.datastore_controller.asset_directory_ )
      ).to_path

      bx.to_pair_stream
    end

    class Collection_Controller__ < Collection_Controller_

      def receive_persist_entity action, ent, & oes_p

        _bytes = Graph_::Actors__::Touch.call(

          action.argument_box[ :dry_run ],

          action, ent, datastore_controller, @kernel, & oes_p )

        _bytes and super
      end

      def datastore_controller
        @action.preconditions.fetch :workspace
      end
    end

    Autoloader_[ Actors__ = ::Module.new ]

    Graph_ = self
  end
end
