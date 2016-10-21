module Skylab::TMX

  class Operations_::Map

    # (this operation is what should become the core operation of tmx)

    class << self
      alias_method :begin, :new
      undef_method :new
    end  # >>

    # -

      def initialize & p
        @_emit = p
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
          __when_missing_requireds [ :@unparsed_node_stream ]  # pretend
        end
      end

      def __when_missing_requireds missing_ivar_a

        @_emit.call :error, :expression, :parse_error, :missing_required_arguments do |y|

          h = Misc_hard_coded_dependency_reflection__[]

          missing_ivar_a.each do |ivar|

            means = h.fetch ivar

            _me = means.say_self_via_ivar ivar, self

            _dep = means.say_dependency_under self

            y << "#{ _me } was not resolved. (use #{ _dep }.)"
          end
          y
        end

        UNABLE_
      end

      # == BEGIN OFF

      # == END OFF

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
        m = PRIMARIES__[ k ]
        if m
          @_current_primary_symbol = k
          @argument_scanner.advance_one
          send m
        else
          __when_unrecognized_primary
        end
      end

      def __when_unrecognized_primary

        name = @argument_scanner.method :head_as_agnostic
        st = method :__primaries_name_stream

        @_emit.call :error, :expression, :parse_error, :unrecognized_primary do |y|

          y << "unrecognized primary #{ say_primary_ name[] }"

          _this_or_this_or_this = say_primary_alternation_ st[]

          y << "expecting #{ _this_or_this_or_this }"
        end

        UNABLE_
      end

      def __primaries_name_stream
        _ = Stream_.call PRIMARIES__.keys do |sym|
          Common_::Name.via_variegated_symbol sym
        end
        _  # todo
      end

      PRIMARIES__ = {
        order: :__parse_order_expression,
        json_file_stream: :__parse_json_file_stream,
        result_in_tree: :__parse_result_in_tree,
        select: :__parse_select_expression,
      }

      Misc_hard_coded_dependency_reflection__ = Lazy_.call do

        # hypothetically we can generate some of this with [ta] magnetics meh

        o = Home_::Models_::Means
        {
          :result_in_tree => o[ :primary, :order, :primary ],
          :@unparsed_node_stream => o[ :primary, :json_file_stream, :human ],
        }
      end

      # -- the 'order' primary

      def __parse_order_expression

        reo = Home_::Models_::Reorderation.via_parse_client__ self, & @_emit
        if reo
          _modifications.add_reorderation reo
        else
          reo
        end
      end

      # -- the 'select' primary

      def __parse_select_expression
        if _parse_formal_attribute
          _attr = remove_instance_variable :@_formal_attribute
          _modifications.add_select _attr
        else
          UNABLE_
        end
      end

      # -- simple, argument-like primaries

      def __parse_json_file_stream

        x = _expect_trueish_primary_value
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

      def _parse_formal_attribute

        _store :@_formal_attribute, parse_formal_attribute_
      end

      def parse_formal_attribute_

        _ac = ( @_attribute_cache ||= AttributeCache___.new Home_::Attributes_ )

        _k = @argument_scanner.head_as_normal_symbol

        attr = _ac.lookup_formal_attribute_via_normal_symbol__ _k, & @_emit

        if attr
          @argument_scanner.advance_one
        end
        attr
      end

      def _when_contextually_invalid_primary

        sym = @_current_primary_symbol

        @_emit.call :error, :expression, :parse_error, :contextually_invalid do |y|

          means = Misc_hard_coded_dependency_reflection__[].fetch sym

          _me = means.say_self_via_symbol sym, self

          _dep = means.say_dependency_under self

          y << "#{ _me } must occur after #{ _dep }."
        end
        UNABLE_
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

      def _expect_trueish_primary_value
        if @argument_scanner.no_unparsed_exists
          self._COVER_ME_no_argument_for_primary @_current_primary_symbol
        else
          x = @argument_scanner.gets_one_as_is
          if x
            x
          else
            self._COVER_ME_falseish_argument_value_when_expected_trueish @_current_primary_symbol
          end
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
  end

  # ==

  class ProcBasedSimpleExpresser_ < ::Proc  # stowaway!
    alias_method :express_into, :call
    undef_method :call
  end

  # ==
end
# #tombstone: temporary: report on no files found for glob
