module Skylab::TanMan

  module Models_::Starter

    # the "silos" "starter" and "graph" have this in common:
    #
    #   - both are represented in the config, and both are represented
    #     similarly. a single {graph|starter} is "selected", which means
    #     that some representation of a filesystem path is stored to the
    #     config, as a [#br-009] "assignment line".
    #
    #   - as such, both can be "unresolvable references", i.e. the config
    #     can have a path that does not have a referent on the filesystem.
    #
    # and then:
    #
    #   - starters (unlike graphs) can "splay", meaning we can list the
    #     available doo-hahs. (we could try to do this for graphs too
    #     with some kind of clever globbing etc but meh.)

    DEFAULT_STARTER_ = 'minimal.dot'

  if false  # #open [#007.D.1] (on stack)

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

    def line_stream_against_value_fetcher vfetch
      Here_::Actions__::Lines.via__(
        vfetch, self, @kernel, & handle_event_selectively )
    end

    def to_path

      @__path ||= ::File.join(
        Here_.path_for_directory_as_collection_,
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

          bx = Common_::Box.new
          bx.add :workspace, ws

          o.preconditions bx

          o.mutate_formal_properties do | fo |
            Models_::Workspace.common_properties.box.each_key do | sym |
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

      include Common_::Event::ReceiveAndSendMethods

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
      # #[#fi-012.8] abstraction candidate for entity/collection operation
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

        _store :@normal_entity, ent
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

        Common_::Event.inline_OK_with(
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

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    Build_collection__ = -> kr, & oes_p do

      Home_.lib_.system.filesystem.directory_as_collection do | o |

        o.directory_path = Here_.path_for_directory_as_collection_
        o.flyweight_class = Here_
        o.flyweight_arguments = [ kr ]
        o.on_event_selectively = oes_p
      end
    end

    Here_ = self
  end  # if false

  end
end
# #history-A: broke out `list` and `get`
