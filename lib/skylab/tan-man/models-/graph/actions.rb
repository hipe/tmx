module Skylab::TanMan

  class Models_::Graph

    edit_entity_class(

      :persist_to, :graph,  # go thru our own custom c.c for now

      :required, :property, :digraph_path )

    class << self
      def action_class  # luckily we want all our (one) action(s) to be this way
        TanMan_::Model_::Document_Entity.action_class
      end
    end  # >>

    Actions = make_action_making_actions_module

    module Actions

      Use = make_action_class :Create do

        edit_entity_class(

          :preconditions, [ :graph, :workspace ],

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
      end
    end

    # c r u d

    def intrinsic_create_before_create_in_datastore action, & oes_p

       Graph_::Actors__::Touch.call(

          action.argument_box[ :dry_run ],

          action, self, @preconditions.fetch( :workspace ), @kernel, & oes_p )

        # (result on success is bytes)

    end

    def to_pair_stream_for_persist

      bx = Callback_::Box.new

      bx.add Brazen_::NAME_, ::Pathname.new(
        @property_box.fetch :digraph_path
      ).relative_path_from(
        ::Pathname.new( @preconditions.fetch( :workspace ).asset_directory_ )
      ).to_path

      bx.to_pair_stream
    end

    def natural_key_string
      @property_box.fetch :digraph_path
    end

    class Silo_Daemon < Silo_Daemon

      def precondition_for_self action, id, bx, & oes_p
        Use___.new action, bx, @kernel, & oes_p
      end
    end

    class Use___

      # this is just a completely dumb limiting wrapper to prove that
      # this silo is only using this one operation of the workspace.

      def initialize _action, bx, _k, & _oes_p
        @ws = bx.fetch :workspace
      end

      def receive_persist_entity action, ent, & oes_p
        @ws.receive_persist_entity action, ent, & oes_p
      end
    end

    Autoloader_[ Actors__ = ::Module.new ]

    Graph_ = self
  end
end
