module Skylab::Brazen

  class Collection_Adapters::Couch < Brazen_::Collection::Model_  # see [#038]

    Brazen_::Model::Entity.call self do

      o :desc, -> y do
        y << "manage couch collections."
      end

      o :persist_to, :workspace,
        :preconditions, [ :collection_couch ]

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

      Create = make_action_class :Create

      Ls = make_action_class :List

      Rm = make_action_class :Delete do

        Brazen_::Model::Entity.call self do

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

    # ~ c r u d

    def persist_entity bx, entity, & oes_p

      _ok = entity.intrinsic_persist_before_persist_in_collection bx, & oes_p
      _ok && Couch_::Actors__::Persist[ bx[ :dry_run ], entity, self, & oes_p ]
    end

    def intrinsic_persist_before_persist_in_collection _, & oes_p

      oes_p ||= handle_event_selectively
      Couch_::Actors__::Touch_collection[ self, & oes_p ]
      PROCEDE_  # #note-085
    end

    def entity_via_intrinsic_key id, & oes_p
      Couch_::Actors__::Retrieve_collection_entity[ id, self, @kernel, & oes_p ]
    end

    def to_entity_stream_via_model cls, & oes_p
      Couch_::Actors__::Build_stream.with :model_class, cls,
        :collection, self,
        :kernel, @kernel,
        & oes_p
    end

    def delete_entity action, ent, & oes_p
      _ok = ent.intrinsic_delete_before_delete_in_collection action, & oes_p
      _ok && Couch_::Actors__::Delete[ action, ent, self, & oes_p ]
    end

    def intrinsic_delete_before_delete_in_collection action, & oes_p

      Couch_::Actors__::Delete_collection.call(
        action.trio( :dry_run ),
        action.trio( :force ),
        self,
        _HTTP_remote, & ( oes_p || handle_event_selectively ) )

      # NOTE  :+[#086] any failure from above is ignored - we want the
      # the failure of the one not to prevent the other from proceding
      # (otherwise you wouldn't be able to remove rogue records)

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

    class Silo_Daemon < Silo_Daemon

      def precondition_for_self _action, _id, box, & oes_p
        :"???"  # we might want to use this for write-collection operations
      end

      def precondition_for act, id, box, & oes_p
        box.fetch( :workspace ).entity_via_intrinsic_key id do | * i_a, & ev_p |
          oes_p.call( * i_a  ) do
            ev_p[].new_inline_with :invite_to_action, [ :collection, :couch, :add ]
          end
        end
      end
    end

    class << self
      def HTTP_remote
        Couch_::HTTP_Remote__
      end
    end  # >>

    Couch_ = self
    Collection = Brazen_::Collection
  end
end
