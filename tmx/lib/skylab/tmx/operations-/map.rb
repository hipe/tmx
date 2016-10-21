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

        require 'json'  # meh

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
        st = @argument_scanner
        until st.no_unparsed_exists
          ok = __parse_argument_scanner_head
          ok || break
        end
        ok
      end

      def __parse_argument_scanner_head

        k = @argument_scanner.head_as_normal_symbol
        m = PRIMARIES_[ k ]
        if m
          @_current_primary_symbol = k
          @argument_scanner.advance_one
          send m
        else
          __when_unrecognized_primary
        end
      end

      def __when_unrecognized_primary

        Here_::When_::Unrecognized_primary[ @argument_scanner, @_emit ]
      end

      PRIMARIES_ = {
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
          _modifications.add_reorder_plan plan
        else
          plan
        end
      end

      # -- the 'select' primary

      def __parse_select_expression
        attr = parse_formal_attribute_
        if attr
          _modifications.add_select attr
        else
          UNABLE_
        end
      end

      # -- simple, argument-like primaries

      def __parse_attributes_module_by
        __parse_primary_value_into :@attributes_module_by
      end

      def __parse_json_file_stream

        x = _parse_trueish_primary_value
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
          Here_::When_::Contextually_missing[ :attributes_module_by, @_current_primary_symbol, @_emit ]
        end
      end

      def __parse_formal_attribute_normally

        _k = @argument_scanner.head_as_normal_symbol

        attr = @_attribute_cache.lookup_formal_attribute_via_normal_symbol__ _k, & @_emit

        if attr
          @argument_scanner.advance_one
        end
        attr
      end

      def _when_contextually_invalid_primary
        Here_::When_::Contextually_invalid_primary[ @_current_primary_symbol, @_emit ]
      end

      def _modifications
        @_modifications ||= begin
          @_stream_modifiers_were_used = true
          @result_in_tree = false
          Home_::Models_::MapModificationIndex.new
        end
      end

      alias_method :modification_index_, :_modifications

      # --

      def _parse_trueish_primary_value
        kn = _parse_primary_value
        if kn
          x = kn.value_x
          if x
            x
          else
            self._COVER_ME_falseish_argument_value_when_expected_trueish @_current_primary_symbol
          end
        else
          UNABLE_
        end
      end

      def __parse_primary_value_into ivar
        kn = _parse_primary_value
        if kn
          instance_variable_set ivar, kn.value_x ; ACHIEVED_
        else
          UNABLE_
        end
      end

      def _parse_primary_value
        if @argument_scanner.no_unparsed_exists
          self._COVER_ME_argument_value_not_provided_for @_current_primary_symbol
        else
          Common_::Known_Known[ @argument_scanner.gets_one_as_is ]
        end
      end

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
          @_index.levenshtein sym, & p
        end
      end

      def _index
        @_index ||= Home_::Models_::Attribute::Index.new :_eg_args_from_oper_, @module
      end
    end

    # ==

    Here_ = self
  end

  # ==

  class ProcBasedSimpleExpresser_ < ::Proc  # stowaway!
    alias_method :express_into, :call
    undef_method :call
  end

  # ==
end
# #pending-rename: branch down
# #tombstone: temporary: report on no files found for glob
