module Skylab::TanMan

  class Models_::Starter  # re-opening

    edit_entity_class(
      :persist_to, :starter,
      :property, :name )

    class << self

      def path_for_directory_as_collection_
        @__path ||= TanMan_.dir_pathname.join( RELPATH___ ).to_path
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
          @___col ||= Build_collection__[ @kernel ]
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

      @__path ||= ::File.join(
        Starter_.path_for_directory_as_collection_,
        property_value_via_symbol( :name ) )
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

        @__fs ||= Build_collection__[ @kernel ]
      end
    end

    Build_collection__ = -> kr do

      Brazen_::Data_Stores::Directory_as_Collection.new(
        kr
      ) do | o |
        o.directory_path = Starter_.path_for_directory_as_collection_
        o.filesystem = TanMan_.lib_.system.filesystem
        o.flyweight_class = Starter_
      end
    end

    Starter_ = self
  end
end
