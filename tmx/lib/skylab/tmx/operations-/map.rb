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
      end

      attr_writer(
        :argument_scanner,
        :unparsed_node_stream,
      )

      def execute

        @_attribute_cache = AttributeCache___.new Home_::Attributes_  # might expose..

        if @argument_scanner.no_unparsed_exists
          _attempt_to_produce_unparsed_stream
        else
          self._THIS_IS_NEXT
        end
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

      def _attempt_to_produce_unparsed_stream

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

      # define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
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
