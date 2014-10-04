module Skylab::TanMan

  class Models_::Starter

    Brazen_::Model_::Entity[ self, -> do

      o :persist_to, :starter,

        :property, :name

    end ]

    class << self
      def collection_controller
        Collection_Controller__
      end

      def dir_pn_instance
        @dpn ||= TanMan_.dir_pathname.join RELPATH__
      end

      def write * x_a
        Starter_::Actors__::Write.via_iambic x_a
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

        Entity_::Add_check_for_missing_required_properties[ self ]

        include Brazen_.model.retrieve_methods

        def produce_any_result
          send_one_entity
        end
      end
    end

    def to_path
      to_pathname.to_path
    end

    def to_pathname
      @pn ||= Starter_.dir_pn_instance.join property_value :name
    end

    class Collection_Controller__ < Brazen_.model.collection_controller

      def persist_entity ent, evr
        ok = normalize_entity_name_via_fuzzy_lookup ent, evr
        ok and super ent, evr
      end

      def datastore_controller
        _silo = @kernel.silo_via_symbol :workspace
        _silo.workspace_via_action @action
      end

      def entity_scan_via_class _cls_, evr

        p = -> do

          fly = Starter_.new_flyweight evr, @kernel
          props = fly.properties

          base_pn = Starter_.dir_pn_instance
          _pn_a = base_pn.children false

          scan = Scan_[].nonsparse_array( _pn_a ).map_reduce_by do |pn|
            props.replace_hash 'name' => pn.to_path
            fly
          end
          p = -> do
            scan.gets
          end
          scan.gets
        end
        Scan_.call do
          p[]
        end
      end
    end

    Starter_ = self
  end
end
