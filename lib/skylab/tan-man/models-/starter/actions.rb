module Skylab::TanMan

  class Models_::Starter

    edit_entity_class(
      :persist_to, :starter,
      :property, :name )

    class << self

      def dir_pn_instance
        @dpn ||= TanMan_.dir_pathname.join RELPATH___
      end

    end  # >>

    RELPATH___ = 'data-documents/starters'.freeze

    Actions = make_action_making_actions_module

    module Actions

      Set = make_action_class :Create do

        edit_entity_class :preconditions, [ :workspace, :starter ]

        def bound_call_against_iambic_stream st
          super
        end
      end

      Ls = make_action_class :List

      class Get < Action_

        edit_entity_class :preconditions, [ :workspace, :starter ]

        include Brazen_.model.retrieve_methods

        def produce_result
          produce_one_entity do | * i_a, & ev_p |
            @on_event_selectively.call( * i_a ) do
              ev_p[].new_inline_with :invite_to_action, [ :starter, :set ]
            end
          end
        end
      end

      Lines = Stub_.new :Lines do | boundish, & oes_p |

        Starter_::Actions__::Lines.new boundish, & oes_p

      end
      class << Lines
        def session k, oes_p, & edit_p
          Starter_::Actions__::Lines::Session.new k, oes_p, & edit_p
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
      @pn ||= Starter_.dir_pn_instance.join property_value_via_symbol :name
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

        Actions::Get.edit_and_call @kernel, oes_p do | o |

          # experimentally hack the enternal API action: give it the workspace
          # we already have and mutate its formals not to know about workspace
          # related arguments. all this ick bc we want to reuse action factory

          o.preconditions workspace: ws

          o.mutate_formal_properties do | fo |
            Models_::Workspace.common_properties.box.each_name do | sym |
              fo.remove sym
            end
          end
        end
      end

      # ~ hook-outs / hook-ins

      def model_class
        Models_::Starter
      end
    end

    class Collection_Controller__ < Collection_Controller_

      def receive_persist_entity action, ent, & oes_p
        _ok = normalize_entity_name_via_fuzzy_lookup ent, & oes_p
        _ok and super action, ent, & oes_p
      end

      def entity_stream_via_model _cls_, & oes_p

        oes_p or self._WHERE

        p = -> do

          fly = Starter_.new_flyweight @kernel, & oes_p
          props = fly.properties

          base_pn = Starter_.dir_pn_instance
          _pn_a = base_pn.children false

          scan = Callback_.stream.via_nonsparse_array( _pn_a ).map_reduce_by do |pn|
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

      def datastore_controller
        @action.preconditions.fetch :workspace
      end
    end

    Starter_ = self
  end
end
