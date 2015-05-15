module Skylab::TanMan

  class Models_::Graph

    edit_entity_class(

      :persist_to, :graph,  # go thru our own custom c.c for now

      :required, :property, :digraph_path )

    DocEnt_ = TanMan_::Model_::Document_Entity

    Actions__ = make_action_making_actions_module

    module Actions__

      Use = make_action_class :Create do

        edit_entity_class(

          :preconditions, [ :graph, :workspace ],

          :properties,
            :workspace_path,  # make this non-required, before w.s silo gets to it
            :starter,
            :created_on )

        def template_value sym

          send :"__template_value_for__#{ sym }__"
        end

        def __template_value_for__created_on__

          @argument_box.fetch :created_on do
            ::Time.now.utc.to_s
          end
        end
      end

      Sync = Action_Stub_.new do
        Graph_::Sync_::Action
      end
    end

    # c r u d

    def intrinsic_persist_before_persist_in_collection bx, & oes_p

      Graph_::Actors__::Touch.call(
        bx[ :dry_run ],
        self,
        bx.fetch( :template_values_provider_ ),
        @preconditions.fetch( :workspace ),
        @kernel,
        & oes_p )

      # (result on success is bytes)

    end

    def to_pair_stream_for_persist

      bx = Callback_::Box.new

      path = @property_box.fetch :digraph_path
      if path.respond_to? :path  # because of a :+[#br-021] hack
        path = path.path
      end

      bx.add Brazen_::NAME_,
        @preconditions.fetch( :workspace ).from_asset_directory_relativize_path__( path )

      bx.to_pair_stream
    end

    def natural_key_string
      @property_box.fetch :digraph_path
    end

    class Silo_Daemon < Silo_Daemon

      def produce_byte_stream_identifiers_at_in i_a, ws, & oes_p
        Produce_byte_stream_identifiers_at_in___.new( i_a, ws, & oes_p ).go
      end

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

      def persist_entity x=nil, ent, & oes_p
        @ws.persist_entity( * x, ent, & oes_p )
      end
    end

    class Produce_byte_stream_identifiers_at_in___

      # mostly this encapsulates the invitation. one day we might push up
      # the logic related to building the stream identifiers into the w.s

      def initialize i_a, ws, & oes_p
        @i_a = i_a
        @workspace = ws
        @on_event_selectively = oes_p
      end

      def go

        @graph_path = @workspace.business_property_value(
            Graph_.persist_to.full_name_i ) do | * i_a, & ev_p |

          if :property_not_found == i_a[ 1 ]
            __invite( i_a, & ev_p )
          else
            @on_event_selectively[ * i_a, & ev_p ]
          end
        end

        @graph_path and __via_graph_path
      end

      def __invite i_a, & ev_p

        @on_event_selectively.call( * i_a ) do

          ev_p[].new_inline_with :invite_to_action, [ :graph, :use ],
            :ok, false  # change the not found from neutral to not OK
              # otherwise clients will not look for this invitation

        end

        UNABLE_
      end

      def __via_graph_path

        path = @workspace.from_asset_directory_absolutize_path__ @graph_path

        @i_a.map do | direction_symbol |

          Brazen_::Collection.const_get(

            Model_::Document_Entity::CONST_VIA_DIRECTION.fetch direction_symbol
          ).via_path path
        end
      end
    end

    Autoloader_[ Actors__ = ::Module.new ]

    Graph_ = self

  end
end
