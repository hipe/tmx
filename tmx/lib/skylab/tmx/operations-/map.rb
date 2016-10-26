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
        @_parse_formal_attribute = :__parse_formal_attribute_the_first_time
        @_seen_last_reorder_plan = false
        @_stream_modifiers_were_used = false
        @unparsed_node_stream = nil
      end

      attr_writer(
        :argument_scanner,
      )

      def execute
        if __parse_modifiers
          if __all_requireds_are_present
            if @_stream_modifiers_were_used
              __modified_stream
            else
              @unparsed_node_stream
            end
          else
            UNABLE_
          end
        else
          UNABLE_
        end
      end

      # --

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

        @unparsed_node_stream.map_reduce_by do |node|

          node_parser.parse node
        end
      end

      # -- hardcoded requireds check

      def __all_requireds_are_present

        if @unparsed_node_stream
          ACHIEVED_
        else
          Here_::When_::Missing_requireds[ [ :@unparsed_node_stream ], @_emit ]
        end
      end

      # -- parse modifiers

      def __parse_modifiers
        ok = true
        until @argument_scanner.no_unparsed_exists
          ok = __parse_argument_scanner_head
          ok || break
        end
        ok
      end

      def __parse_argument_scanner_head

        m = @argument_scanner.match_head_against_primaries_hash PRIMARIES__
        if m
          @argument_scanner.advance_one
          send m
        end
      end

      def when_unrecognized_primary ks_p, listener
        @argument_scanner.when_unrecognized_primary ks_p, & listener
      end

      def get_primary_keys__
        PRIMARIES__.keys
      end

      PRIMARIES__ = {
        attributes_module_by: :__parse_attributes_module_by,
        order: :__parse_order_expression,
        json_file_stream: :__parse_json_file_stream,
        result_in_tree: :__parse_result_in_tree,
        select: :__parse_select_expression,
      }

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

      # -- simple, argument-like primaries

      def __parse_attributes_module_by
        _parse_into :@attributes_module_by
      end

      def __parse_json_file_stream

        x = @argument_scanner.parse_primary_value :must_be_trueish
        if x
          _x_ = Home_::Magnetics::UnparsedNodeStream_via::JSON_FileStream[ x ]
          _store :@unparsed_node_stream, _x_
        else
          UNABLE_
        end
      end

      def __parse_result_in_tree
        if @_stream_modifiers_were_used
          @result_in_tree = true ; ACHIEVED_
        else
          _when_contextually_invalid_primary
        end
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

        _k = @argument_scanner.head_as_normal_symbol

        attr = lookup_attribute_via_normal_symbol_ _k
        if attr
          @argument_scanner.advance_one
        end
        attr
      end

      def lookup_attribute_via_normal_symbol_ k
        @_attribute_cache.lookup_formal_attribute_via_normal_symbol__ k, & @_emit
      end

      def _when_contextually_invalid_primary
        Here_::When_::Contextually_invalid_primary[ _current_primary_symbol, @_emit ]
      end

      def _modifications
        @_modifications ||= begin
          @_stream_modifiers_were_used = true
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

      # --

      def _current_primary_symbol
        @argument_scanner.current_primary_symbol
      end

      define_method :_parse_into, DEFINITION_FOR_THE_METHOD_CALLED_PARSE_INTO_

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      attr_reader(
        :argument_scanner,  # for collaborators
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
# #pending-rename: branch down
# #tombstone: temporary: report on no files found for glob
