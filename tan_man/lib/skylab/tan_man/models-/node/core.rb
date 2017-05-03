module Skylab::TanMan

  class Models_::Node

    class << self

      if false
      def build_sexp_fuzzy_matcher_via_natural_key_fragment s

        rx = /\A#{ ::Regexp.escape s }/i  # :+[#069] case insensitive?. :~+[#ba-015]

        -> stmt do
          rx =~ stmt.label_or_node_id_normalized_string
        end
      end
      end  # if false

      alias_method :new_flyweight_, :new
      undef_method :new
    end  # >>

    # ==

      if false
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
      end  # if false

    class NodesOperatorBranchFacade_TM

      def initialize dc
        @_digraph_controller = dc  # ivar name is #testpoint
      end

      def touch_node_via_label___ label, & p  # #testpoint only (for now)

        _operation :touch, p, label
      end

      def procure_node_via_label_ label, & p

        _operation :retrieve, p, label
      end

      def _operation sym, any_listener, label

        _un = UnsanitizedNode_.new label

        Here_::Magnetics_::Create_or_Touch_or_Delete_via_Node_and_Collection.call_by do |o|

          o.entity = _un

          o.entity_via_created_element_by = -> node_stmt do
            Here_.new_flyweight_.reinit_as_flyweight_ node_stmt
          end

          o.verb_lemma_symbol = sym
          o.document = @_digraph_controller
          o.listener = any_listener
        end
      end

      def lookup_softly_via_node_ID___ node_ID_sym

        to_dereferenced_item_stream__.flush_until_detect do |fly|
          _actual = fly.node_identifier_symbol_
          node_ID_sym == _actual
        end
      end

      def to_dereferenced_item_stream__   # (experimental, currently used only for list action)

        fly = Here_.new_flyweight_

        _st = __to_node_sexp_stream

        _st.map_by do |node_stmt|
          fly.reinit_as_flyweight_ node_stmt
        end
      end

      def __to_node_sexp_stream  # #tespoint

        # it's necessarily confusing: each item of this stream is a NodeStmt

        @_digraph_controller.graph_sexp.to_node_stream
      end

      def to_node_statement_stream___

        # it's necessarily confusing: each item of this stream is a StmtList

        @_digraph_controller.graph_sexp.to_node_statement_stream
      end
    end

    # ==

    class UnsanitizedNode_

      def initialize unsanitized_label_s
        @_ = unsanitized_label_s
      end

      def unsanitized_label_string___
        @_
      end

      def lookup_value_softly_ _
        NOTHING_
      end
    end

    # -

      def reinit_as_flyweight_ node_stmt
        @node_stmt = node_stmt
        self
      end

      def description_under expag

        # (the only reason we need this method is because of #spot2.2 (good reason))

        s = @node_stmt.label_or_node_id_normalized_string  # can't be label, #cov2.4
        expag.calculate do
          component_label s
        end
      end

      def node_label_
        @node_stmt.label
      end

      def node_identifier_symbol_
        @node_stmt.node_ID_symbol_
      end

      attr_reader(
        :node_stmt,  # #testpoint
      )
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
