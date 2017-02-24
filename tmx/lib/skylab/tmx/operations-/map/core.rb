module Skylab::TMX

  class Operations_::Map

    # (this operation is what should become the core operation of tmx)

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize & p

        @attributes_module_by = nil
        @_emit = p
        @_has_pager = false
        @_has_means = false
        @_parse_formal_attribute = :__parse_formal_attribute_the_first_time
        @_seen_last_reorder_plan = false
        @stream_modifiers_were_used = false

        @operator_branch = Zerk_::ArgumentScanner::
          OperatorBranch_via_Hash[ PRIMARIES___ ]
      end

      def json_file_stream_by= x  # for [#006]
        @_has_means = true
        @json_file_stream_by = x
      end

      attr_writer(
        :argument_scanner,
        :attributes_module_by,  # for [#006]
      )

      def execute

        # #coverpoint-1-D needs nil on help (because client)
        # #coverpoint-1-E needs false on fails because API

        x = __parse_modifiers
        if x
          if __all_requireds_are_present
            if @_has_pager
              __flush_paged_stream
            else
              _flush_non_paged_stream
            end
          else
            UNABLE_
          end
        else
          x
        end
      end

      # --

      def __flush_paged_stream
        st = _flush_non_paged_stream
        if st
          pager = @__pager
          pager.stream = st
          pager.execute
        else
          UNABLE_
        end
      end

      def _flush_non_paged_stream
        if @stream_modifiers_were_used
          __modified_stream
        else
          _flush_to_unparsed_node_stream
        end
      end

      def __modified_stream

        if @_modifications.has_reductions
          if @result_in_tree
            _map_reduced_tree
          else
            __map_reduced_stream
          end
        else
          _mapped_stream
        end
      end

      def __map_reduced_stream
        _tree = _map_reduced_tree
        _tree.to_node_stream
      end

      def _map_reduced_tree

        _node_st = _mapped_stream

        Home_::Magnetics_::GroupTree_via_ParsedNodeStream_and_Reductions[
          _node_st, @_modifications.reductions ]
      end

      def _mapped_stream

        if @_modifications.has_derivations

          _st = _mapped_stream_ignorant_of_derivations
          Home_::Magnetics_::MappedStream_via_Derivations_and_MappedStream.call(
            @_modifications, _st )
        else
          _mapped_stream_ignorant_of_derivations
        end
      end

      def _mapped_stream_ignorant_of_derivations

        node_parser = Home_::Models_::Node::Parsed::Parser.new(
          @_modifications, @_attribute_cache._index, & @_emit )

        st = _flush_to_unparsed_node_stream
        if st
          st.map_reduce_by do |node|
            node_parser.parse node
          end
        end
      end

      def _flush_to_unparsed_node_stream

        _p = remove_instance_variable :@json_file_stream_by

        st = _p.call( & @_emit )
        if st
          Home_::Models_::Node::Parsed::Unparsed::Stream_via_json_file_stream[ st ]
        end
      end

      # -- hardcoded requireds check

      def __all_requireds_are_present

        if @_has_means
          ACHIEVED_
        else
          Here_::When_::Missing_requireds[ [ :unparsed_node_stream ], @_emit ]
        end
      end

      # -- parse modifiers

      def __parse_modifiers

        ok = true

        if ! @argument_scanner.no_unparsed_exists

          @__matcher = @argument_scanner.matcher_for(
            :primary, :value, :against_branch, @operator_branch )

          begin
            ok = __parse_one_primary_term
            ok || break
          end until @argument_scanner.no_unparsed_exists
        end

        ok
      end

      def __parse_one_primary_term

        m = @__matcher.gets
        if m
          @argument_scanner.advance_one
          send m
        else
          m  # #coverpoint-1-D/#coverpoint-1-E
        end
      end

      # --

      Description_proc_reader___ = Lazy_.call do

        {
          page_by: -> y do
            y << "experimental.."
          end,

          order: -> y do
            y << "<attribute name>  uses the ordering schema (if any) for"
            y << "that attribute. multiple order modifiers may be chained together"
            y << "to the extent allowed by the participating attributes."
          end,

          result_in_tree: -> y do
            y << "when `order` is used, internally successive orderings"
            y << "are represented in a tree structure with each branch node"
            y << "being a grouping of the multiple nodes with the same value"
            y << "for the attribute being ordered by. ordinarily this tree"
            y << "is flattened to produce the end result of nodes. this"
            y << "option returns the raw tree as a value rather than such"
            y << "a stream of nodes."
          end,

          select: -> y do
            y << "<attribute name>  similar to the SQL term of the same name,"
            y << "adds (if necessary) this attribute to the set of attributes"
            y << "that will be populated with values in the nodes of the"
            y << "resulting stream"
            y << nil
            y << "designed to be piped. hackish but useful example (from CLI):"
            y << nil
            y << "    tmx map -select framework | awk '{if ( $2 ~ /\\[br\\]/ ) print}'"
            y << nil
            y << "the above shows all the sidesystem that (still) use the [br] framework"
          end,
        }
      end

      # --

      PRIMARIES___ = {

        page_by: :__parse_page_by,  # break alpha. order - higher-level higher

        attributes_module_by: :__parse_attributes_module_by,
        order: :__parse_order_expression,
        json_file_stream: :__parse_json_file_stream,
        json_file_stream_by: :__parse_json_file_stream_by,
        result_in_tree: :__parse_result_in_tree,
        select: :__parse_select_expression,
      }

      def at_from_syntaxish item
        @argument_scanner.advance_one  # per our own local parse model
        send item.branch_item_value
      end

      # -- the 'order' primary

      def __parse_order_expression

        plan = Home_::Models::Reorder::Plan_via_parse_client[ self, & @_emit ]
        if plan
          if @_seen_last_reorder_plan
            self._COVER_ME_reorderings_are_closed
          else
            if plan.produces_final_group_list
              @_seen_last_reorder_plan = true
            end
            _modifications.add_reorder_plan plan
          end
        else
          plan
        end
      end

      # -- PAGE BY

      def __parse_page_by
        if @_has_pager
          self._COVER_ME_cannot_have_multiple_pagers
        elsif @stream_modifiers_were_used && @result_in_tree
          self._COVER_ME_cannot_have_pager_and_result_in_tree
        else
          pager = Here_::Pager___.new( self ).execute
          if pager
            @_has_pager = true
            @__pager = pager
            ACHIEVED_
          else
            pager
          end
        end
      end

      # -- the 'select' primary

      def __parse_select_expression
        attr = parse_formal_attribute_
        if attr
          if attr.is_derived
            _modifications.add_derived__ attr, self
          else
            _modifications.add_nonderived_select__ attr
          end
        else
          UNABLE_
        end
      end

      # -- parse primaries (most complicated to least)

      def __parse_json_file_stream_by
        p = @argument_scanner.parse_primary_value :must_be_trueish
        if p
          @_has_means = true
          @json_file_stream_by = p
          ACHIEVED_
        end
      end

      def __parse_json_file_stream
        st = @argument_scanner.parse_primary_value :must_be_trueish
        if st
          @_has_means = true
          @json_file_stream_by = -> { st }
          ACHIEVED_
        end
      end

      def __parse_result_in_tree
        if @stream_modifiers_were_used
          if @_has_pager
            self._COVER_ME_not_with_pager
          else
            @result_in_tree = true ; ACHIEVED_
          end
        else
          _when_contextually_invalid_primary
        end
      end

      def __parse_attributes_module_by
        __parse_into :@attributes_module_by
      end

      # -- support for primaries

      def parse_formal_attribute_
        send @_parse_formal_attribute
      end

      def __parse_formal_attribute_the_first_time

        if __resolve_attribute_cache
          @_parse_formal_attribute = :__parse_formal_attribute_normally
          send @_parse_formal_attribute
        else
          UNABLE_
        end
      end

      def __resolve_attribute_cache

        p = remove_instance_variable :@attributes_module_by
        if p
          _mod = p[]
          _mod || fail
          @_attribute_cache = AttributeCache___.new _mod
          ACHIEVED_
        else
          Here_::When_::Contextually_missing[ :attributes_module_by, _current_primary_symbol, @_emit ]
        end
      end

      def __parse_formal_attribute_normally

        sym = @argument_scanner.head_as_normal_symbol
        if sym
          attr = lookup_attribute_via_normal_symbol_ sym
          if attr
            @argument_scanner.advance_one
          end
          attr
        else
          sym
        end
      end

      def lookup_attribute_via_normal_symbol_ k
        @_attribute_cache.lookup_formal_attribute_via_normal_symbol__ k, & @_emit
      end

      def _when_contextually_invalid_primary
        Here_::When_::Contextually_invalid_primary[ _current_primary_symbol, @_emit ]
      end

      def _modifications
        @_modifications ||= begin
          @stream_modifiers_were_used = true
          @result_in_tree = false
          Home_::Models_::MapModificationIndex.new
        end
      end

      def modification_index
        # (do not autovivify. do not clutter ivar namespace with more state).
        if instance_variable_defined? :@_modifications
          @_modifications
        end
      end

      # -- meta-support for parsing primaries

      def _current_primary_symbol
        @argument_scanner.current_primary_symbol
      end

      define_method :__parse_into, DEFINITION_FOR_THE_METHOD_CALLED_PARSE_INTO_

      # == boilerplate

      # -- help screen boilerplate

      def is_branchy
        false
      end

      def description_proc_reader_for_didactics
        Description_proc_reader___[]
      end

      def to_item_normal_tuple_stream_for_didactics
        @operator_branch.to_loadable_reference_stream.map_by do |key_x|
          [ :primary, key_x ]
        end
      end

      # ~

      attr_reader(
        :argument_scanner,  # for collaborators
        :operator_branch,  # for [#006] feature injection
        :stream_modifiers_were_used,  # ditto
      )
    # -

    # ==

    class AttributeCache___

      def initialize mod
        @module = mod
      end

      def lookup_formal_attribute_via_normal_symbol__ sym, & p
        attr = _index.formal_via_normal_symbol sym
        if attr
          attr
        else
          @_index.express_levenshtein__ sym, & p
        end
      end

      def _index
        @_index ||= Home_::Models_::Attribute::Index.new :_eg_args_from_oper_, @module
      end
    end

    # ==

    Here_ = self
  end
end
