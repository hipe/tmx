module Skylab::Brazen
  # ->
    class Actionesque::Factory < ::Module  # see [#046]

      class << self

        def make *a
          new do
            init_via_model_action_entity( * a )
          end
        end
      end  # >>

      def initialize & p
        instance_exec( & p )
      end

    private

      def init_via_model_action_entity model_cls, action_base_cls, extmod

        @_action_base_class_of_application = action_base_cls
        @_extmod = extmod

        __make_generated_action_base_class model_cls
      end

      def __make_generated_action_base_class _MODEL_CLASS_

        cls = ::Class.new @_action_base_class_of_application

        const_set :Semi_Generated_Action, cls

        @__generated_action_base_class = cls

        cls.class_exec do

          extend Semi_Generated_Module_Methods___

          define_singleton_method :model_class do
            _MODEL_CLASS_
          end

        end
        NIL_
      end

    public

      def make_actions_module

        mod = ::Module.new

        _FACTORY_ = self

        mod.define_singleton_method :make_action_class do | const, & edit_p |
          _FACTORY_.__make_action_class const, & edit_p
        end

        mod
      end

      def __make_action_class const, & edit_p

        cls = send :"__make__#{ const }__"

        if block_given?
          cls.class_exec( & edit_p )
        end

        cls
      end

    private

      def __make__Create__

        cls = _begin_class

        @_extmod.call cls,
          :flag, :property, :dry_run,
          :flag, :property, :verbose

        cls.include Create_Methods___
        cls
      end

      def __make__List__

        cls = _begin_class

        @_extmod.call cls,
          :inflect, :verb, :with_lemma, 'list', :noun, :plural,
          :flag, :property, :verbose

        cls.include List_Methods___
        cls
      end

      def __make__Delete__

        cls = _begin_class

        @_extmod.call cls,
          :inflect, :verb, :with_lemma, 'delete',
          :required, :property, NAME_SYMBOL,
          :flag, :property, :dry_run,
          :flag, :property, :verbose

        cls.include Delete_Methods___

        cls
      end

      def _begin_class
        ::Class.new @__generated_action_base_class
      end

      module Semi_Generated_Module_Methods___

        def instance_description_proc
          cls = self
          -> y do
            nf = cls.name_function
            y << "#{ nf.inflected_verb } #{ nf.inflected_noun }"
          end
        end
      end

      Semi_Generated_Instance_Methods__ = ::Module.new

      module Create_Methods___

        include Semi_Generated_Instance_Methods__

        def init_formal_properties_ fp_bx

          # the first time during the lifetime of this action that our formals
          # are accessed, add in *all* model class formal next to our "adverb"
          # formals (continued at #note-135..)

          super fp_bx  # any preconditions will add their properties here. maybe [#018] order sensitive

          st = _model_class.properties.to_value_stream
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

            @parent_node.accept_selective_event_listener__ @on_event_selectively

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

          @edited_entity.persist_via_action self, & handle_event_selectively
        end
      end

      module List_Methods___

        include Semi_Generated_Instance_Methods__

        def produce_result
          entity_collection.to_entity_stream_via_model(
            _model_class, & handle_event_selectively )
        end
      end

      module Retrieve_Methods

        include Semi_Generated_Instance_Methods__

      private

        def produce_one_entity & oes_p
          oes_p ||= handle_event_selectively
          @__entity_stream = entity_collection.to_entity_stream_via_model(
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
            __build_single_entity_resolved_with_ambiguity
          end
          one
        end

        def __build_single_entity_resolved_with_ambiguity

          Common_::Event.inline_neutral_with(

            :single_entity_resolved_with_ambiguity,
            :model, _model_class,
            :describable_source, entity_collection

          ) do | y, o |

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there is more than one #{ _lemma }. #{
             }using the last one."
          end
        end

        def __for_one_resolve_entity_when_had_none & oes_p

          oes_p.call :error, :component_not_found do

            Home_.event( :Component_Not_Found ).new_with(
              :component_association, _model_class,
              :ACS, entity_collection,
            )
          end

          UNABLE_
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

      module Delete_Methods___

        include Semi_Generated_Instance_Methods__

        def produce_result

          __init_selective_listener_proc_for_delete

          oes_p = handle_event_selectively

          ok = __via_args_resolve_subject_entity

          ok &&= @subject_entity.intrinsic_delete_before_delete_in_collection(
            self, & oes_p )

          ok and entity_collection.delete_entity self, @subject_entity, & oes_p
        end

        def __init_selective_listener_proc_for_delete

          _ = Common_::Event.produce_handle_event_selectively_through_methods

          upstream_oes_p = @on_event_selectively

          _oes_p = _.full self, :while_deleting_entity do | * i_a, & ev_p |

            upstream_oes_p[ * i_a, & ev_p ]
          end

          @on_event_selectively = _oes_p

          NIL_
        end

        def __via_args_resolve_subject_entity
          _ok = __via_args_resolve_identifier
          _ok && __via_identifier_resolve_subject_entity
        end

        def __via_args_resolve_identifier
          _name_s = @argument_box.fetch NAME_SYMBOL
          id = _model_class.node_identifier.with_local_entity_identifier_string _name_s
          @identifier = id
          ACHIEVED_
        end

        def __via_identifier_resolve_subject_entity
          @subject_entity = entity_collection.entity_via_intrinsic_key @identifier, & handle_event_selectively
          @subject_entity ? ACHIEVED_ : UNABLE_
        end
      end

      module Semi_Generated_Instance_Methods__
      private

        def entity_collection  # :+#public-API #hook-in
          @preconditions.fetch _model_class.persist_to.full_name_symbol
        end

        def _model_class
          self.class.silo_module
        end
      end
      AF_ = self
    end
  # <-
end
