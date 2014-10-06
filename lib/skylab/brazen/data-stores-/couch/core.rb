module Skylab::Brazen

  class Data_Stores_::Couch < Brazen_::Data_Store_::Model_  # see [#038]

    Brazen_::Model_::Entity[ self, -> do

      o :desc, -> y do
        y << "manage couch datastores."
      end

      o :persist_to, :workspace

      o :description, -> y do
        y << "the name of the database"
      end,
      :ad_hoc_normalizer, -> arg, val_p, ev_p do
        x = arg.value_x
        if /\A[-a-z0-9]+\z/ =~ x
          val_p[ x ]
        else
          ev_p[ :error, :name_must_be_lowercase_alphanumeric_with_dashes,
                :name_s, x, :ok, false, nil ]
        end ; nil
      end,
      :required,
      :property, :name


      o :description, -> y do
        y << "the HTTP host to connect to (default: #{ property_default })"
      end,
      :default, 'localhost',
      :property, :host


      o :description, -> y do
        y << "the HTTP port to connect to (default: #{ property_default })"
      end,
      :default, '5984',
      :ad_hoc_normalizer, -> arg, val_p, ev_p do
        x = arg.value_x
        if x
          if /\A[0-9]{1,4}\z/ =~ x
            val_p[ x ]
          else
            ev_p[ :error, :port_must_be_one_to_four_digits, :port_s, x,
                  :ok, false, nil ]
          end
        end
      end,
      :property, :port

    end ]

    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Create

      Ls = make_action_class :List

      Rm = make_action_class :Delete do

        Entity_[][ self, -> do
          o :description, -> y { y << 'always necessary for now.' },
            :flag, :property, :force
        end ]
      end
    end

    def description
      o = @property_box
      "#{ o[ :name ] } on #{ o[ :host ] }:#{ o[ :port ] }"
    end

    def datastore_controller_via_entity _ent
      self
    end

    # ~ for create

    def persist_entity entity, _event_receiver
      Couch_::Actors__::Persist[ entity, self ]
    end

    def any_native_create_before_create_in_datastore
      Couch_::Actors__::Touch_datastore[ self, @event_receiver ]
      PROCEDE_  # #note-085
    end

    # ~ for retrieve (one)

    def entity_via_identifier id, evr
      Couch_::Actors__::Retrieve_datastore_entity[ id, self, evr, @kernel ]
    end

    # ~ for retrieve (list)

    def entity_scan_via_class cls, evr
      Couch_::Actors__::Scan.with :model_class, cls,
        :datastore, self,
        :event_receiver, evr, :kernel, @kernel
    end

    # ~ for delete entity

    def delete_entity ent, evr
      ok = ent.any_native_delete_before_delete_in_datastore evr
      ok && Couch_::Actors__::Delete[ ent, self, evr ]
    end

    # ~ for delete self

    def any_native_delete_before_delete_in_datastore evr
      _remote = _HTTP_remote
      _ok = Couch_::Actors__::Delete_datastore[
        self, @action_formal_properties, _remote, evr ]
      # NOTE we ignore the above - we want failure of the one not to prevent
      # the other from proceding (otherwise you couldn't remove rogue records)
      PROCEDE_
    end

    # ~ for actors

    def put body, * x_a
      _HTTP_remote.put body, x_a
    end

    def get uri_tail, * x_a
      _HTTP_remote.get uri_tail, x_a
    end

    def delete uri_tail, * x_a
      x_a.push :entity_identifier_strategy, :append_URI_tail
      x_a.push :URI_tail, uri_tail
      _HTTP_remote.delete x_a
    end

  private

    def _HTTP_remote
      @HTTP_remote ||= bld_HTTP_remote
    end

    def bld_HTTP_remote
      Couch_.HTTP_remote.new( * @property_box.at( :name, :port, :host ) )
    end

  public  # ~ hook in's

    def as_precondition_via_preconditions precons
      @preconditions = precons
      # (we used to touch the database here)
      self
    end

    class Collection_Controller__ < Brazen_.model.collection_controller

    end

    class Silo_Controller__ < Brazen_.model.silo_controller

      def wrap_action_precondition_not_resolved_from_identifier_event ev
        x_a = ev.to_iambic
        x_a.push :invite_to_action, [ :datastore, :couch, :add ]
        build_event_via_iambic x_a, & ev.message_proc
      end
    end

    class << self

      def HTTP_remote
        Couch_::HTTP_Remote__
      end
    end

    Couch_ = self
    Data_Store_ = Brazen_::Data_Store_
  end
end
