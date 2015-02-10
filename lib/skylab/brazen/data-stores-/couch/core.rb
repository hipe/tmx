module Skylab::Brazen

  class Data_Stores_::Couch < Brazen_::Data_Store_::Model_  # see [#038]

    Brazen_::Model_::Entity.call self do

      o :desc, -> y do
        y << "manage couch datastores."
      end

      o :persist_to, :workspace

      o :description, -> y do
        y << "the name of the database"
      end,
      :ad_hoc_normalizer, -> arg, & oes_p do

        if arg.value_x.nil?
          # fallthru. let missing required check catch it.
          arg

        elsif /\A[-a-z0-9]+\z/ =~ arg.value_x
          arg

        else
          oes_p.call :error, :invalid_property_value do
            Brazen_.event.inline_not_OK_with(
              :name_must_be_lowercase_alphanumeric_with_dashes,
                :name_s, arg.value_x )
          end
        end
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
      :ad_hoc_normalizer, -> arg, & oes_p do
        x = arg.value_x
        if x
          if /\A[0-9]{1,4}\z/ =~ x
            arg
          else
            oes_p.call :error, :invalid_property_value do
              Brazen_.event.inline_not_OK_with(
                :port_must_be_one_to_four_digits, :port_s, x )
            end
          end
        else
          arg
        end
      end,
      :property, :port

    end

    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Create

      Ls = make_action_class :List

      Rm = make_action_class :Delete do

        Brazen_::Model_::Entity.call self do

          o :description,
            -> y do
              y << "always necessary for now."
            end,
            :flag, :property, :force
        end
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

    def receive_persist_entity action, entity
      Couch_::Actors__::Persist[ action.argument_box[ :dry_run ], entity, self ]
    end

    def any_native_create_before_create_in_datastore
      Couch_::Actors__::Touch_datastore[ self, & handle_event_selectively ]
      PROCEDE_  # #note-085
    end

    # ~ for retrieve (one)

    def entity_via_identifier id, & oes_p
      Couch_::Actors__::Retrieve_datastore_entity[ id, self, @kernel, & oes_p ]
    end

    # ~ for retrieve (list)

    def entity_stream_via_model cls, & oes_p
      Couch_::Actors__::Build_stream.with :model_class, cls,
        :datastore, self,
        :kernel, @kernel,
        & oes_p
    end

    # ~ for delete entity

    def receive_delete_entity action, ent, & oes_p
      _ok = ent.intrinsic_delete action, & oes_p
      _ok && Couch_::Actors__::Delete[ action, ent, self, & oes_p ]
    end

    # ~ for delete self

    def intrinsic_delete action, & oes_p

      Couch_::Actors__::Delete_datastore.call(
        action.trio( :dry_run ),
        action.trio( :force ),
        self,
        _HTTP_remote, & ( oes_p || handle_event_selectively ) )

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

  public  # ~ hook out's & hook in's

    def as_precondition_via_preconditions precons
      @preconditions = precons
      # (we used to touch the database here)
      self
    end

    class Silo_Daemon < Brazen_.model.silo_daemon_class

      def provide_Action_preconditioN id, g, & oes_p  # :+#public-API
        super id, g do | * i_a, & ev_p |
          oes_p.call( * i_a ) do
            ev = ev_p[]
            x_a = ev.to_iambic
            x_a.push :invite_to_action, [ :datastore, :couch, :add ]
            ev.class.inline_via_iambic x_a, & ev.message_proc
          end
        end
      end
    end

    class Silo_Controller__ < Brazen_.model.silo_controller_class

    end

    class Collection_Controller__ < Brazen_.model.collection_controller_class

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
