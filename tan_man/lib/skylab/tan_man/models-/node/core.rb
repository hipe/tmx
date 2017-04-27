module Skylab::TanMan

  class Models_::Node

    if false
    edit_entity_class(

      :persist_to, :node,

      :preconditions, [ :dot_file ],

      :property, :id,

      :required,
      :ad_hoc_normalizer, -> arg, & oes_p do
        Here_::NodeController_::NormalKnownness_via_QualifiedKnownness_of_Name[ arg, self, & oes_p ]
      end,
      :property, :name )
    end  # if false

    if false
      Add = make_action_class :Create do

        edit_entity_class(
          :flag, :property, :ping,
          :reuse, Model_::DocumentEntity.IO_properties )

      private

        def via_arguments_produce_bound_call
          if @argument_box[ :ping ]
            bound_call_for_ping_
          else
            super
          end
        end
      end
    end  # if false

    class << self

      if false
      def build_sexp_fuzzy_matcher_via_natural_key_fragment s

        rx = /\A#{ ::Regexp.escape s }/i  # :+[#069] case insensitive?. :~+[#ba-015]

        -> stmt do
          rx =~ stmt.label_or_node_id_normalized_string
        end
      end
      end  # if false

      alias_method :new_flyweight__, :new
      undef_method :new
    end  # >>

    if false
    class Silo_Daemon < Silo_daemon_base_class_[]

      def node_collection_controller_via_document_controller dc, & oes_p

        # :+#actionless-collection-controller-experiment

        bx = Common_::Box.new
        bx.add :dot_file, dc

        precondition_for_self :_no_action_,
          @silo_module.node_identifier,
          bx,
          & oes_p
      end

      def precondition_for_self act, id, box, & oes_p
        Collection_Controller__.new act, box, @silo_module, @kernel, & oes_p
      end
    end

    class Collection_Controller__ < Model_::DocumentEntity::Collection_Controller

      include Common_Collection_Controller_Methods_

      def to_preconditions_plus_self__
        bx = @precons_box_.dup
        bx.add(
          @model_class.name_function.as_lowercase_with_underscores_symbol,
          self )
        bx
      end

      # ~ c r u d

      def entity_via_natural_key_fuzzily s

        p = Here_.build_sexp_fuzzy_matcher_via_natural_key_fragment s

        st = to_node_sexp_stream

        found_a = []
        begin
          x = st.gets
          x or break
          _does_match = p[ x ]
          if _does_match
            if s == x.label  # case sensitive
              found_a.clear.push x
              break
            else
              found_a.push x
            end
          end
          redo
        end while nil

        case 1 <=> found_a.length
        when  0
          _entity_via_node found_a.fetch 0
        when -1
          self._BEHAVIOR_IS_NOT_YET_DESIGNED  # #open similar to [#012]
        end
      end

      def entity_via_intrinsic_key node_identifier, & oes_p

        label_s = node_identifier.entity_name_string

        node = to_node_sexp_stream.flush_until_detect do | node_ |
          label_s == node_.label
        end

        if node

          _entity_via_node node

        else

          if oes_p
          oes_p.call :info, :component_not_found do
            Common_::Event.inline_neutral_with :component_not_found,
              :entity_name_string, node_identifier.entity_name_string
          end
          end

          UNABLE_
        end
      end

      def to_entity_stream_via_model model
        if @model_class == model
          to_node_sexp_stream.map_by do | node |
            _entity_via_node node
          end
        end
      end

      def retrieve_any_node_with_id sym
        to_node_sexp_stream.flush_until_detect do | node |
          sym == node.node_id
        end
      end

      def to_node_sexp_stream
        document_.at_graph_sexp :to_node_stream
      end

      def to_node_statement_stream
        document_.at_graph_sexp :to_node_statement_stream
      end

      def at_graph_sexp i
        document_.at_graph_sexp i
      end

      def add_node_via_id_and_label id_s, label_s

        node = _begin_node :name, label_s, :id, id_s

        node and begin
          produce_relevant_sexp_via_touch_entity node
        end
      end

      def touch_node_via_label s

        node = _begin_node :name, s

        node and begin
          produce_relevant_sexp_via_touch_entity node
        end
      end

      def _begin_node * x_a, & oes_p
        Here_.edit_entity @kernel, ( oes_p || @on_event_selectively ) do | o |
          o.edit_via_iambic x_a
        end
      end

      def persist_entity bx, byte_downstream_ID, entity, & oes_p

        _ok = _mutate_via_verb_and_entity :create, entity, & oes_p
        _ok and _commit_changes bx, byte_downstream_ID, & oes_p
      end

      def produce_relevant_sexp_via_touch_entity entity

        _mutate_via_verb_and_entity :touch, entity
      end

      def _mutate_via_verb_and_entity verb_i, entity, & oes_p

        Here_::Magnetics__::Create_or_Touch_or_Delete_via_Node_and_Collection.call(
          verb_i,
          entity,
          document_,
          @kernel, & ( oes_p || @on_event_selectively ) )
      end

      def _entity_via_node node

        @model_class.new( @kernel, & @on_event_selectively ).
          __init_via_node_stmt_and_immutable_preconditions node, @precons_box_
      end

      def _commit_changes bx, byte_downstream_ID, & oes_p

        document_.persist_into_byte_downstream_reference(
          byte_downstream_ID,
          :is_dry, bx[ :dry_run ],
          & oes_p )
      end
    end

    def __init_via_node_stmt_and_immutable_preconditions node_stmt, precon_bx

      bx = Common_::Box.new
      bx.add :name, node_stmt.label

      @preconditions = precon_bx
      @property_box = bx
      @node_stmt = node_stmt

      self
    end
    end  # if false

    # -

      def reinit_as_flyweight__ node_stmt
        @_node_stmt = node_stmt
        self
      end

      def node_name_symbol_
        @_node_stmt.node_id
      end
    # -
    # ==

    module Magnetics_
      Autoloader_[ self ]
      lazily :Create_or_Touch_or_Delete_via_Node_and_Collection do |const|
        const_get :Create_or_Retrieve_or_Touch_via_NodeName_and_Collection, false
        const_defined? const, false or self.__OOPS
      end
    end

    Here_ = self

    # ==
    # ==
  end
end
# #history-A.1: begin modernization for end of [br]-era
