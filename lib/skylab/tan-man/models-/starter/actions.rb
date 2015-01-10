module Skylab::TanMan

  class Models_::Starter

    Entity_.call self,

        :persist_to, :starter,

        :property, :name


    class << self

      def dir_pn_instance
        @dpn ||= TanMan_.dir_pathname.join RELPATH__
      end
    end
    RELPATH__ = 'data-documents/starters'.freeze

    Actions = make_action_making_actions_module

    module Actions

      Set = make_action_class :Create

      class Set
        use_workspace_as_datastore_controller
      end

      Ls = make_action_class :List

      class Get < Action_

        use_workspace_as_datastore_controller

        include Brazen_.model.retrieve_methods

        def produce_any_result
          send_one_entity
        end
      end

      Lines = Stub_.new :Lines do | boundish, & oes_p |

        Starter_::Actions__::Lines.new boundish, & oes_p

      end
    end

    def to_path
      to_pathname.to_path
    end

    def to_pathname
      @pn ||= Starter_.dir_pn_instance.join property_value_via_symbol :name
    end

    class Collection_Controller__ < Collection_Controller_

      use_workspace_as_dsc

      def persist_entity ent, & oes_p
        ok = normalize_entity_name_via_fuzzy_lookup ent, & oes_p
        ok and super ent, & oes_p
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
    end

    Starter_ = self
  end
end
