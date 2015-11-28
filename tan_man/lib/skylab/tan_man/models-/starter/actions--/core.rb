module Skylab::TanMan

  class Models_::Starter  # re-opening

    edit_entity_class(
      :persist_to, :starter,
      :property, :name )

    class << self

      def path_for_directory_as_collection_
        @__path ||= __DIRECTORY
      end

      def __DIRECTORY
        ::File.join( Home_.sidesystem_path_, 'data-documents/starters' ).freeze
      end
    end  # >>

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
          @___col ||= Build_collection__[ @kernel, & @on_event_selectively ]
        end
      end

      class Get < Action_

        edit_entity_class :preconditions, [ :workspace, :starter ]

        include Brazen_::Actionesque::Factory::Retrieve_Methods

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

      @__col ||= __build_collection_via_kernel
    end

    def __build_collection_via_kernel

      Hybrid_Collection_Controller___.new(
        @preconditions, self.class, @kernel, & @on_event_selectively )
    end

    class Silo_Daemon < Silo_daemon_base_class_[]

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

        # the collection for starters is the config file

        box.fetch :workspace
      end
    end

    class Hybrid_Collection_Controller___

      # use the filesystem when reading the available collection,
      # use the workspace when writing the currently selected entity.

      include Callback_::Event::Selective_Builder_Receiver_Sender_Methods

      include Common_Collection_Controller_Methods_

      def initialize bx, mc, k, & oes_p
        @kernel = k
        @model_class = mc
        @on_event_selectively = oes_p
        @ws = bx.fetch :workspace
      end

      def persist_entity x=nil, ent, & oes_p

        o = Persist_in_Collection2_IFF_Found_in_Collection1___.new( & oes_p )
        o.arg = x
        o.collection1 = self
        o.collection2 = @ws
        o.entity = ent
        o.workspace = @ws
        o.execute
      end

      def to_entity_stream_via_model cls, & oes_p
        _fs.to_entity_stream_via_model cls, & oes_p
      end

      def _fs
        @__fs ||= __build_directory_as_collection
      end

      def __build_directory_as_collection
        Build_collection__[ @kernel, & @on_event_selectively ]
      end
    end

    class Persist_in_Collection2_IFF_Found_in_Collection1___

      # we are storing the entity in the workspace IFF it is a "valid"
      # entity. validity is determined solely by whether the entity is
      # found in some collecion (fuzzily) using natural keys. we use this
      # process to normalize the name, too.
      #
      # :+[#br-117] abstraction candidate for entity normalization
      # :+#CC-abstraction-candidate

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      attr_writer(
        :arg,
        :collection1,
        :collection2,
        :entity,
        :workspace,
      )

      def execute

        ok = __find_entity_in_collection_one
        ok &&= __via_normal_entity_maybe_normalize_subject_entity
        ok && __persist_subject_entity
      end

      def __find_entity_in_collection_one

        arg_s = @entity.natural_key_string

        ent = @collection1.one_entity_against_natural_key_fuzzily_(
          arg_s, & @on_event_selectively )

        if ent
          @normal_entity = ent
          ACHIEVED_
        else
          ent  # above emitted
        end
      end

      def __via_normal_entity_maybe_normalize_subject_entity

        prp = @entity.class.natural_key_string_property
        _NAME = prp.name_symbol

        normal_name_x = @normal_entity.property_value_via_symbol _NAME
        current_name_x = @entity.property_value_via_symbol _NAME

        if normal_name_x == current_name_x
          ok_x = ACHIEVED_
        else
          ok_x = @entity.edit do | sess |
            sess.edit_with _NAME, normal_name_x
          end
          if ok_x
            @on_event_selectively.call :info, :normalized_value do
              __build_normalized_value_event normal_name_x, current_name_x, prp
            end
          end
        end

        ok_x
      end

      def __build_normalized_value_event normal_x, mine_x, prp

        Callback_::Event.inline_OK_with(
          :normalized_value,
          :prop, prp,
          :previous_x, mine_x,
          :current_x, normal_x
        ) do | y, o |

          y << "using #{ ick o.current_x } for #{ par o.prop } #{
           }(inferred from #{ ick o.previous_x })"
        end
      end

      def __persist_subject_entity

        @workspace.persist_entity( * @arg, @entity, & @on_event_selectively )
      end
    end

    Build_collection__ = -> kr, & oes_p do

      Home_.lib_.system.filesystem.directory_as_collection do | o |

        o.directory_path = Starter_.path_for_directory_as_collection_
        o.flyweight_class = Starter_
        o.kernel = kr
        o.on_event_selectively = oes_p
      end
    end

    Starter_ = self
  end
end
