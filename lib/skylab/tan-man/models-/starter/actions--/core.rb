module Skylab::TanMan

  class Models_::Starter  # re-opening

    edit_entity_class(
      :persist_to, :starter,
      :property, :name )

    class << self

      def __dir_pn_instance
        @dpn ||= TanMan_.dir_pathname.join RELPATH___
      end
    end  # >>

    RELPATH___ = 'data-documents/starters'.freeze

    Actions__ = make_action_making_actions_module

    module Actions__

      Set = make_action_class :Create do

        edit_entity_class :preconditions, [ :workspace, :starter ]

        def produce_result
          super
        end

        def entity_collection
          # sanity
        end
      end

      Ls = make_action_class :List do

        edit_entity_class :preconditions, EMPTY_A_

        def entity_collection
          @___col ||= Collection_in_Filesystem_Controller__.new @kernel
        end
      end

      class Get < Action_

        edit_entity_class :preconditions, [ :workspace, :starter ]

        include Brazen_::Model.common_retrieve_methods

        def produce_result
          produce_one_entity do | * i_a, & ev_p |
            @on_event_selectively.call( * i_a ) do
              ev_p[].new_inline_with :invite_to_action, [ :starter, :set ]
            end
          end
        end
      end
    end

    def line_stream_against_value_fetcher vfetch
      Starter_::Actions__::Lines.via__(
        vfetch, self, @kernel, & handle_event_selectively )
    end

    def to_path
      to_pathname.to_path
    end

    def to_pathname
      @pn ||= Starter_.__dir_pn_instance.join property_value_via_symbol :name
    end

    def entity_collection
      @__col ||= Hybrid_Collection_Controller___.new @preconditions, self.class, @kernel
    end

    class Silo_Daemon < Silo_Daemon

      # ~ custom exposures

      def lines_via__ value_fetcher, workspace, & oes_p
        starter = starter_in_workspace workspace, & oes_p
        starter and begin
          starter.line_stream_against_value_fetcher value_fetcher
        end
      end

      def starter_in_workspace ws, & oes_p

        Actions__::Get.edit_and_call @kernel, oes_p do | o |

          # experimentally hack the enternal API action: give it the workspace
          # we already have and mutate its formals not to know about workspace
          # related arguments. all this ick bc we want to reuse action factory

          bx = Callback_::Box.new
          bx.add :workspace, ws

          o.preconditions bx

          o.mutate_formal_properties do | fo |
            Models_::Workspace.common_properties.box.each_name do | sym |
              fo.remove sym
            end
          end
        end
      end

      # ~ hook-outs / hook-ins

      def precondition_for_self _act, _id, box, & oes_p

        # the datastore for starters is the config file

        box.fetch :workspace
      end
    end

    class Hybrid_Collection_Controller___

      # use the filesystem when reading the available collection,
      # use the workspace when writing the currently selected entity.

      def initialize bx, mc, k
        @kernel = k
        @model_class = mc
        @ws = bx.fetch :workspace
      end

      def persist_entity x=nil, ent, & oes_p

        _ok = __normalize_entity_name_via_fuzzy_lookup ent, & oes_p
        _ok and begin
          @ws.persist_entity( * x, ent, & oes_p )
        end
      end

      def __normalize_entity_name_via_fuzzy_lookup ent, & oes_p

        # :+#CC-abstraction-candidate

        ent_ = one_entity_against_natural_key_fuzzily_(
          ent.natural_key_string, & oes_p )

        ent_ and begin
          ent.normalize_property_value_via_normal_entity(
            ent.class.natural_key_string, ent_, & oes_p )
          ACHIEVED_
        end
      end

      def to_entity_stream_via_model cls, & oes_p
        _fs.to_entity_stream_via_model cls, & oes_p
      end

      # ~

      include Callback_::Event::Selective_Builder_Receiver_Sender_Methods
      include Common_Collection_Controller_Methods_

      def _fs
        @fs ||= Collection_in_Filesystem_Controller__.new @kernel
      end
    end

    class Collection_in_Filesystem_Controller__

      def initialize k
        @kernel = k
      end

      # ~ #hook-out's

      def to_entity_stream_via_model _cls_, & oes_p

        p = -> do

          fly = Starter_.new_flyweight @kernel, & oes_p
          props = fly.properties

          base_pn = Starter_.__dir_pn_instance

          _pn_a = base_pn.children false

          scan = Callback_::Stream.via_nonsparse_array( _pn_a ).map_reduce_by do |pn|
            props.replace_hash 'name' => pn.to_path
            fly
          end
          p = -> do
            scan.gets
          end
          scan.gets
        end

        Callback_.stream do
          p[]
        end
      end
    end

    Starter_ = self
  end
end
