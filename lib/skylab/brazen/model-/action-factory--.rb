module Skylab::Brazen

  class Model_

    class Action_Factory__ < ::Module  # see [#046]

      class << self

        def make *a
          new do
            init_via_model_action_entity( * a )
          end
        end

        def retrieve_methods
          Retrieve_Methods__
        end
      end

      def initialize & p
        instance_exec( & p )
      end

    private

      def init_via_model_action_entity m_cls, a_cls, e_cls
        @mc = m_cls ; @cls1 = a_cls ; @ent = e_cls
        resolve_cls2
      end

      def resolve_cls2

        @cls2 = const_set :Semi_Generated_Action, ::Class.new( @cls1 )

        _MODEL_CLASS_ = @mc

        @cls2.class_exec do

          extend Brazen_::Entity::Common_Module_Methods_  # before next line

          class << self
            alias_method :build_action_props, :build_immutable_properties_stream_with_random_access_
          end

          extend Semi_Generated_Module_Methods__

          define_singleton_method :model_class do
            _MODEL_CLASS_
          end

        end ; nil
      end

    public

      def make_actions_module
        mod = ::Module.new
        _FACTORY_ = self
        mod.define_singleton_method :make_action_class do |i, & p|
          _FACTORY_.make_action_class_via_name_and_proc i, p
        end
        mod
      end

      def make_action_class_via_name_and_proc i, p
        cls = send :"make_#{ i }"
        p and cls.class_exec( & p )
        cls
      end

    private

      def make_Create
        cls = begin_class
        @ent.call cls do
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end
        cls.include Create_Methods__
        cls
      end

      def make_List
        cls = begin_class
        @ent.call cls do
          o :inflect, :verb, :with_lemma, 'list', :noun, :plural
          o :flag, :property, :verbose
        end
        cls.include List_Methods__
        cls
      end

      def make_Delete
        cls = begin_class
        @ent.call cls do
          o :inflect, :verb, :with_lemma, 'delete'
          o :required, :property, NAME_
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end
        cls.include Delete_Methods__
        cls
      end

    private

      def begin_class
        ::Class.new @cls2
      end

      module Semi_Generated_Module_Methods__

        def has_description
          true
        end

        def description_block
          cls = self
          -> y do
            nf = cls.name_function
            y << "#{ nf.inflected_verb } #{ nf.inflected_noun }"
          end
        end
      end

      Semi_Generated_Instance_Methods__ = ::Module.new

      module Create_Methods__

        include Semi_Generated_Instance_Methods__

        def init_formal_properties_ x

          # the first time during the lifetime of this action that our formals
          # are accessed, add in *all* model class formal next to our "adverb"
          # formals (continued at #note-135..)

          super x  # any preconditions will add their properties here. maybe [#018] order sensitive
          st = _model_class.properties.to_stream
          prp = st.gets
          if prp
            bx = @formal_properties.to_mutable_box_like_proxy
            @formal_properties = bx  # may be same object
            begin
              if bx.has_name prp.name_symbol
                self._NEEDS_POLICY  # #todo
              end
              bx.add prp.name_symbol, prp
              prp = st.gets
            end while prp
          end
          @formal_properties
        end

        def produce_result

          if @parent_node

            # experimentally, the child action "takes over" the parent

            @parent_node.__accept_selective_event_listener @on_event_selectively

            @edited_entity = @parent_node.first_edit do | o |
              o.preconditions @preconditions
              o.edit_magnetically_from_box @argument_box
            end

            @parent_node = nil
          else

            @edited_entity = _model_class.
                  edited @kernel, handle_event_selectively do |o|
              o.preconditions @preconditions
              o.edit_magnetically_from_box @argument_box
            end
          end

          @edited_entity and via_edited_entity_produce_result
        end

        def via_edited_entity_produce_result  # :+#public-API
          @edited_entity.result_for_persist self, & handle_event_selectively
        end
      end

      module List_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_result
          entity_collection.entity_stream_via_model(
            _model_class, & handle_event_selectively )
        end
      end

      module Retrieve_Methods__

        include Semi_Generated_Instance_Methods__

      private

        def send_one_entity
          @entity = produce_one_entity
          @entity and __via_entity_send_one
        end

        def produce_one_entity & oes_p
          oes_p ||= handle_event_selectively
          @__entity_stream = entity_collection.entity_stream_via_model(
            _model_class, & oes_p )
          __via_entity_stream_and_dsc_for_one_produce_entity( & oes_p )
        end

        def __via_entity_stream_and_dsc_for_one_produce_entity & oes_p
          one = @__entity_stream.gets
          if one
            x = @__entity_stream.gets
            if x
              one = x
              had_many = true
              x = @__entity_stream.gets
              while x
                one = x
                x = @__entity_stream.gets
              end
            end
          end
          @__entity_stream = nil
          if one
            if had_many
              __via_dsc_for_one_produce_entity_when_had_many_via_last one, & oes_p
            else
              one
            end
          else
            __for_one_resolve_entity_when_had_none( & oes_p )
          end
        end

        def __via_dsc_for_one_produce_entity_when_had_many_via_last one, & oes_p
          oes_p.call :info, :single_entity_resolved_with_ambiguity do
            bld_single_entity_resolved_with_ambiguity
          end
          one
        end

        def bld_single_entity_resolved_with_ambiguity
          build_neutral_event_with :single_entity_resolved_with_ambiguity,
              :model, _model_class,
              :describable_source, entity_collection do |y, o|

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there is more than one #{ _lemma }. #{
             }using the last one."
          end
        end

        def __for_one_resolve_entity_when_had_none & oes_p
          oes_p.call :error, :entity_not_found do
            bld_entity_not_found_event
          end
          UNABLE_
        end

        def bld_entity_not_found_event
          build_not_OK_event_with :entity_not_found,
              :model, _model_class,
              :describable_source, entity_collection do |y, o|

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there are no #{ plural_noun _lemma }"
          end
        end

        def __via_entity_send_one
          maybe_send_event :payload do
            bld_single_entity_resolved_without_ambiguity
          end
        end

        def bld_single_entity_resolved_without_ambiguity
          build_OK_event_with :entity,
              :entity, @entity, :is_completion, true do |y, o|

            y << "#{ o.entity.class.name_function.as_human } is #{
             } #{ ick o.entity.natural_key_string }"
          end
        end
      end

      module Delete_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_result

          __init_selective_listener_proc_for_delete

          oes_p = handle_event_selectively

          ok = __via_args_resolve_subject_entity

          ok &&= @subject_entity.intrinsic_delete_before_delete_in_datastore(
            self, & oes_p )

          ok and entity_collection.receive_delete_entity self, @subject_entity, & oes_p
        end

        def __init_selective_listener_proc_for_delete
          @on_event_selectively = event_lib.
            produce_handle_event_selectively_through_methods.
              full self, :while_deleting_entity do | * i_a, & ev_p |
            maybe_receive_event_via_channel i_a, & ev_p
          end
        end

        def __via_args_resolve_subject_entity
          _ok = __via_args_resolve_identifier
          _ok && __via_identifier_resolve_subject_entity
        end

        def __via_args_resolve_identifier
          _name_s = @argument_box.fetch NAME_
          id = _model_class.node_identifier.with_local_entity_identifier_string _name_s
          @identifier = id
          PROCEDE_
        end

        def __via_identifier_resolve_subject_entity
          @subject_entity = entity_collection.entity_via_intrinsic_key @identifier, & handle_event_selectively
          @subject_entity ? PROCEDE_ : UNABLE_
        end
      end

      module Semi_Generated_Instance_Methods__
      private

        def entity_collection  # :+#public-API #hook-in
          @preconditions.fetch _model_class.persist_to.full_name_i
        end

        def _model_class
          self.class.model_class
        end
      end
    end
  end
end
