module Skylab::TanMan

  class Models_::Node

    class << self

      alias_method :new_flyweight_, :new
      undef_method :new
    end  # >>

    # (as entity (flyweight) starts #here1)

    # ==

    class NodesOperatorBranchFacade_TM

      def initialize dc
        @_digraph_controller = dc  # ivar name is #testpoint
      end

      def touch_node_via_label_ label, & p  # #testpoint

        _via_label :touch, p, label
      end

      def one_entity_against_natural_key_fuzzily_ name_s, & p

        # (bascially `entity_via_natural_key_fuzzily`, which was erased now #todo)

        Home_::ModelMagnetics_::OneEntity_via_NaturalKey_Fuzzily.call_by do |o|
          o.natural_key_head = name_s
          o.entity_stream_by = method :to_node_entity_stream_
          o.model_module = Here_
          o.listener = p
        end
      end

      def procure_node_via_label__ label, & p

        _via_label :retrieve, p, label
      end

      def procure_node_removal_via_label__ label, & p

        _via_label :delete, p, label
      end

      def _via_label sym, any_listener, label

        _un = UnsanitizedNode___.new label

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

        to_node_entity_stream_.flush_until_detect do |fly|
          _actual = fly.node_identifier_symbol_
          node_ID_sym == _actual
        end
      end

      def to_node_entity_stream_

        # experimental, would-be API method `to_dereferenced_item_stream`
        # (currently used only for the `ls` action and one other #testpoint-only)

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

    class UnsanitizedNode___  # might go away..

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

    # -  # :#here1

      def reinit_as_flyweight_ node_stmt
        @node_stmt = node_stmt
        self
      end

      def duplicate_as_flyweight_
        self.class.new_flyweight_.reinit_as_flyweight_ @node_stmt
      end

      def description_under expag

        # (the only reason we need this method is because of #spot2.2 (good reason))

        s = @node_stmt.label_or_node_id_normalized_string  # can't be label, #cov2.4
        expag.calculate do
          component_label s
        end
      end

      def natural_key_string  # hook-out for #fuzzy-lookup
        get_node_label_  # hi.
      end

      def get_node_label_
        @node_stmt.get_label_
      end

      def node_identifier_symbol_
        @node_stmt.node_ID_symbol_
      end

      attr_reader(
        :node_stmt,  # #testpoint
      )

      def HELLO_NODE  # during dev
        NOTHING_
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
