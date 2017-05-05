module Skylab::TanMan

  class Models_::Association

    # "view and edit associations"

    # (begins as entity class #here1)

    class AssocOperatorBranchFacade_  # #testpoint
      # was: Collection_Controller___ < Model_::DocumentEntity::Collection_Controller

      def initialize dc
        @_digraph_controller = dc  # #testpoint
      end

      def procure_remove_association__ compound_key, & p

        touch_or_delete_by_ do |o|

          o.from_and_to_labels( * compound_key )
          o.verb_lemma_symbol = :delete
          o.listener = p
        end
      end

      def touch_by__  # #testpoint
        touch_or_delete_by_ do |o|
          yield o
          o.verb_lemma_symbol = :touch
        end
      end

      def touch_or_delete_by_

        Here_::TouchOrDeleteAssociation_via_FromNode_and_ToNode___.call_by do |o|
          yield o
          o.entity_via_element_by = method :__entity_via_edge_stmt
          o.digraph_controller = @_digraph_controller
        end
      end

      if false  # until "hear"
      def touch_association_via_node_labels src_lbl_s, dst_lbl_s, & oes_p

        oes_p ||= @on_event_selectively

        asc = _begin_association :from_node_label, src_lbl_s,
          :to_node_label, dst_lbl_s, & oes_p

        asc and begin

          asc_ = _fuzzy_match_nodes_of_association asc
          if asc_
            asc = asc_
          end

          info = _info_via_into_collection_marshal_entity(
            nil, nil, asc, & oes_p )
          info and asc
        end
      end

      # (for "sync")
      def touch_association_via_IDs src_id_sym, dst_id_sym, & oes_p

        asc = _begin_association :from_node_ID, src_id_sym,
          :to_node_ID, dst_id_sym

        asc and begin

          info = _info_via_into_collection_marshal_entity(
            nil, nil, asc, & oes_p )

          info and asc
        end
      end

      def _fuzzy_match_nodes_of_association asc

        cc = @precons_box_.fetch :node

        f_o = cc.entity_via_natural_key_fuzzily asc.dereference :from_node_label

        t_o = cc.entity_via_natural_key_fuzzily asc.dereference :to_node_label

        a = nil
        if f_o
          a = []
          a.push :from_node_label, f_o.dereference( :name )
        end

        if t_o
          a ||= []
          a.push :to_node_label, t_o.dereference( :name )
        end

        if a
          asc.via_iambic a
        end
      end

      Info___ = ::Struct.new :did_mutate
      end  # if false (for the old methods of the old collection controller)

      def __entity_via_edge_stmt edge_stmt
        Here_.new_flyweight_ do |o|
          yield o
          o.reinit_as_flyweight_ edge_stmt
        end
      end

      attr_reader(
        :_digraph_controller,  # #testpoint
      )
    end

    # ==

    # ==

    class << self
      alias_method :new_flyweight_, :new
      undef_method :new
    end  # >>

    # - :#here1

      def initialize
        if block_given?
          yield self
          freeze
        end
      end

      def reinit_as_flyweight_ edge_stmt
        @edge_stmt = edge_stmt ; self
      end

      # ~ ( #cov2.7

      def _DO_WRITE_COLLECTION_= x
        @_DO_WRITE_COLLECTION_ = Common_::KnownKnown.yes_or_no x ; nil
      end

      def _DO_WRITE_COLLECTION_
        @_DO_WRITE_COLLECTION_.value_x
      end

      # ~ )

      attr_reader(
        :edge_stmt,  # #testpoint - an easy copout for testing
      )

      def HELLO_ASSOCIATION  # just during development
        NOTHING_
      end

    # -

    Here_ = self
  end
end
