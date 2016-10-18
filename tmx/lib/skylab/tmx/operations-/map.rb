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
        @unparsed_node_stream = nil
        @STREAM_MODIFIERS_WERE_USED = false
      end

      attr_writer(
        :argument_scanner,
      )

      def execute
        if __parse_modifiers
          if __all_requireds_are_present
            if @STREAM_MODIFIERS_WERE_USED
              __something
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

      # ~ hardcoded requireds check

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

      def __stream_thru_modifiers
        @_ok = true
        @_additional_formal_attributes = nil
        begin
          if __front_argument_looks_like_primary
            if ! __parse_primary
              break
            end
          elsif ! __parse_map_term
            break
          end
          @scn.no_unparsed_exists ? break : redo
        end while above
        @_ok && __flush_mapped_stream
      end

      def __front_argument_looks_like_primary
        Looks_like_opt__[ @scn.current_token ]
      end

      def __parse_map_term

        _normal_human_string = @scn.current_token

        attr = @_attribute_cache.lookup_formal_attribute_via_normal_human_string(
          _normal_human_string, & @_emit )

        if attr
          @scn.advance_one
          ( @_additional_formal_attributes ||= [] ).push attr
          ACHIEVED_
        else
          attr  # did whine
        end
      end

      def __flush_mapped_stream

        if _store :@__raw_stream, _attempt_to_produce_stream
          __do_flush_mapped_stream
        end
      end

      def __do_flush_mapped_stream

        # for each entity, and then for each attribute (of each entity)..

        require 'json'

        a = remove_instance_variable :@_additional_formal_attributes

        index = @_attribute_cache._index

        remove_instance_variable( :@__raw_stream ).map_by do |node|

          parsed_node = node.parse_against index, & @_emit

          ProcBasedSimpleExpresser_.new do |y|

            buff = node.get_filesystem_directory_entry_string

            if parsed_node
              a.each do |attr|
                buff << SPACE_
                attr.of( parsed_node ).express_into buff
              end
            end

            y << buff
          end
        end
      end

      # == END OFF

      # ~ parse modifiers

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

      def __parse_json_file_stream

        x = _expect_trueish_primary_value
        if x

          _x_ = Home_::Magnetics::UnparsedNodeStream_via::JSON_FileStream[ x ]

          _store :@unparsed_node_stream, _x_
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
        ::Kernel._K
        fo = _index.formal_via_human str
        if fo
          fo
        else
          @_index.levenshtein str, :as_human, & p
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
