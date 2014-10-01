module Skylab::TanMan

  class Models_::Starter

    Brazen_::Model_::Entity[ self, -> do

      o :persist_to, :starter,

        :property, :name

    end ]

    RELPATH__ = 'data-documents/starters'.freeze

    class << self
      def collection_controller
        Collection_Controller__
      end
    end

    Actions = make_action_making_actions_module

    module Actions

      Set = make_action_class :Create

      class Set
        use_workspace_as_datastore_controller
      end

      Ls = make_action_class :List

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

          base_pn = TanMan_.dir_pathname.join RELPATH__
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
