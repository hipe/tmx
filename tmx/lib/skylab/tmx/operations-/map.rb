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

        require 'json'  # meh

        _s_a = remove_instance_variable :@_selected_attributes

        _index = @_attribute_cache._index

        node_parser = Home_::Models_::Node::Parsed::Parser.new(
          _s_a, _index, & @_emit )

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

          h = Hard_coded_magnetics_reflection___[]

          missing_ivar_a.each do |ivar|

            sct = h.fetch ivar

            _name_st = Stream_.call sct.primary_symbols do |sym|
              Common_::Name.via_variegated_symbol sym
            end

            _x_or_y = say_primary_alternation_ _name_st

            y << "#{ sct.as_human } was not resolved. (use #{ _x_or_y }.)"
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
        json_file_stream: :__parse_json_file_stream,
        select: :__parse_select_expression,
      }

      Hard_coded_magnetics_reflection___ = Lazy_.call do

        # (hypothetically we can generate this sort of thing with the [ta]
        # magnetics library but it's really not worth it for now)

        Means__ = ::Struct.new :as_human, :primary_symbols
        {
          :@unparsed_node_stream => Means__[
            "unparsed node stream",
            [
              :json_file_stream,
            ] ],
        }
      end

      def __parse_select_expression
        @_stream_modifiers_were_used = true
        if _parse_formal_attribute
          ( @_selected_attributes ||= [] ).push remove_instance_variable :@_formal_attribute
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def __parse_json_file_stream

        x = _expect_trueish_primary_value
        if x
          _x_ = Home_::Magnetics::UnparsedNodeStream_via::JSON_FileStream[ x ]
          _store :@unparsed_node_stream, _x_
        else
          UNABLE_
        end
      end

      def _parse_formal_attribute

        _ac = ( @_attribute_cache ||= AttributeCache___.new Home_::Attributes_ )

        _k = @argument_scanner.head_as_normal_symbol

        attr = _ac.lookup_formal_attribute_via_normal_symbol__ _k, & @_emit

        if attr
          @argument_scanner.advance_one
          @_formal_attribute = attr
          ACHIEVED_
        else
          UNABLE_
        end
      end

      # --

      def __TO_USE_nonempty_unparsed_node_stream_via_unparsed_node_stream

        st = @unparsed_node_stream

        # nasty peek, it's this or peek the stream or don't check for this

        if st.upstream.files.length.zero?
          __when_empty_upstream
        else
          st  # wee
        end
      end

      def __when_empty_upstream

        # more nasty peeking..

        glob = @unparsed_node_stream.upstream.glob

        @_emit.call :error, :expression, :zero_nodes do |y|
          y << "found no files for #{ glob }"
        end

        UNABLE_
      end

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
        @_index ||= Home_::Models_::Attribute::Index.new @module
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
