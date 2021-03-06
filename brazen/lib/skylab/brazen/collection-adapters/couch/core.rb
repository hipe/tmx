module Skylab::Brazen

  class CollectionAdapters::Couch < Home_::Model  # see [#038]

    Home_::Modelesque.entity self do

      o :branch_description, -> y do
        y << "manage couch collections."
      end

      o :persist_to, :workspace,
        :preconditions, [ :collection_couch ]

      o :description, -> y do
        y << "the name of the database"
      end,
      :ad_hoc_normalizer, -> qkn, & p do

        if ! qkn.is_effectively_known

          qkn.to_knownness  # fallthru. let missing required's catch it

        elsif /\A[-a-z0-9]+\z/ =~ qkn.value

          qkn.to_knownness  # valid!

        else
          p.call :error, :invalid_property_value do
            Common_::Event.inline_not_OK_with(
              :name_must_be_lowercase_alphanumeric_with_dashes,
                :name_s, qkn.value )
          end
        end
      end,
      :required,
      :property, :name


      o :description, -> y do

        prp = action_reflection.front_properties.fetch :host

        y << "the HTTP host to connect to (default: #{ prp.default_value })"
      end,

      :default, 'localhost',
      :property, :host


      o :description, -> y do

        prp = action_reflection.front_properties.fetch :port

        y << "the HTTP port to connect to (default: #{ prp.default_value })"

      end,
      :default, '5984',
      :ad_hoc_normalizer, -> qkn, & p do
        if qkn.is_known_known
          x = qkn.value
        end
        if x
          if /\A[0-9]{1,4}\z/ =~ x
            qkn.to_knownness
          else
            p.call :error, :invalid_property_value do
              Common_::Event.inline_not_OK_with(
                :port_must_be_one_to_four_digits, :port_s, x )
            end
          end
        else
          qkn.to_knownness
        end
      end,
      :property, :port

    end

    Actions = make_action_making_actions_module

    module Actions

      Create = make_action_class :Create

      Ls = make_action_class :List

      Rm = make_action_class :Delete do

        Home_::Modelesque.entity self do

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

    def persist_entity bx, entity, & p

      _ok = entity.intrinsic_persist_before_persist_in_collection bx, & p

      _ok && Couch_::Magnetics::PersistEntity_via_Entity_and_Collection.call(
        bx[ :dry_run ], entity, self, & p )
    end

    def intrinsic_persist_before_persist_in_collection _, & p

      p ||= handle_event_selectively
      Couch_::Magnetics::TouchCollection_via_Collection[ self, & p ]
      ACHIEVED_  # [#038.B]
    end

    def entity_via_intrinsic_key id, & p
      Couch_::Magnetics::Retrieve_collection_entity[ id, self, @kernel, & p ]
    end

    def to_entity_stream_via_model cls, & p

      Couch_::Magnetics::EntityStream_via_Collection.via(
        :model_class, cls,
        :collection, self,
        :kernel, @kernel,
        & p )
    end

    def delete_entity action, ent, & p
      _ok = ent.intrinsic_delete_before_delete_in_collection action, & p
      _ok && Couch_::Magnetics::DeleteEntity_via_Entity_and_Collection[ action, ent, self, & p ]
    end

    def intrinsic_delete_before_delete_in_collection action, & p

      Couch_::Magnetics::DeleteCollection_via_Collection.call(
        action.knownness( :dry_run ),
        action.knownness( :force ),
        self,
        _HTTP_remote, & ( p || handle_event_selectively ) )

      # NOTE  :+[#086] any failure from above is ignored - we want the
      # the failure of the one not to prevent the other from proceding
      # (otherwise you wouldn't be able to remove rogue records)

      ACHIEVED_
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

    class Silo_Daemon < Home_::Silo::Daemon

      def precondition_for_self _action, _id, box, & p
        :"???"  # we might want to use this for write-collection operations
      end

      def precondition_for act, id, box, & p
        box.fetch( :workspace ).entity_via_intrinsic_key id do | * i_a, & ev_p |
          p.call( * i_a  ) do
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

    JSON_ = Lazy_.call do
      Home_.lib_.JSON
    end

    Couch_ = self
  end
end
