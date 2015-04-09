module Skylab::Snag

  module Models::Node

    class Scan__  # the embodiment of [#059] scanners

      class << self
        def produce_scan_from_lines lines
          Scanner_From_Lines__.new lines
        end
      end

      def initialize p, upstream
        @p = p ; @upstream = upstream ; nil
      end

      def reduce_by & p
        Scan__.new p, self
      end

      def stop_when & p
        Stopper__.new p, self
      end

      def each
        if block_given?
          x = nil
          yield x while x = gets
          nil
        else
          to_enum
        end
      end

      def gets
        x = @upstream.gets
        while x
          _pass = @p[ x ]
          _pass and break
          x = @upstream.gets
        end
        x
      end

      def stop
        @upstream.stop ; nil
      end

      class Stopper__ < self
        def initialize( * )
          p = -> do
            x = @upstream.gets
            if x
              _do_stop = @p[ x ]
              if _do_stop
                @upstream.stop
                p = EMPTY_P_
              end
            end
            x
          end
          @gets_p = -> do
            p[]
          end
          super
        end
        def gets
          @gets_p.call
        end
      end

      class Scanner_From_Lines__ < self

        def initialize normalized_line_producer
          @fly = Node_.build_flyweight
          @line_producer = normalized_line_producer
          @scn = Snag_::Library_::StringScanner.new EMPTY_S_
        end

        def gets
          @line ||= @line_producer.gets
          @line and gets_when_line_and_expecting_node
        end

        def stop
          @line_producer.stop ; nil
        end

      private

        def gets_when_line_and_expecting_node
          @fly.clear
          @scn.string = @line
          d = @scn.skip ID_RX__
          if d
            gets_when_line_starts_with_identifier d
          else
            gets_when_line_failed_to_start_with_identifier
          end
        end

        def gets_when_line_failed_to_start_with_identifier
          @fly.set_parse_failure 'identifier',
            @line[ 0, 9 ],  # arbitrary amount
            @line,
            @line_producer.line_number,
            @line_producer.pathname
          @line = nil
          @fly
        end

        def gets_when_line_starts_with_identifier width_d
          id_s = @line[ 0, width_d ]
          @md = ID_RX__.match id_s  # eew do it again
          @indexes = @fly.indexes
          @d = CONTENT_START_INDEX__
          @md[ :prefix ] and prcs_prefix
          @fly.first_line = @line
          prcs_integer_and_identifier_body
          prcs_first_line_body
          @fly.is_valid = true
          @line = nil
          prcs_any_extra_lines
          @fly
        end

        def prcs_prefix
          @indexes.identifier_prefix.begin = @d
          @d += @md[ :prefix ].length + Models::Identifier::PREFIX_SEPARATOR_WIDTH
          @indexes.identifier_prefix.end = @d - 1
        end

        def prcs_integer_and_identifier_body
          @indexes.identifier_body.begin = @d
          @indexes.integer.begin = @d
          @indexes.integer.end = @d + @md[ :integer ].length - 1
          @d += @md[ :identifier_body ].length
          @indexes.identifier_body.end = @d - 1
        end

        def prcs_first_line_body
          @scn.skip WHITE_RX__
          @indexes.body.begin = @scn.pos
          @indexes.body.end = @line.length - 1
        end

        def prcs_any_extra_lines
          @line = @line_producer.gets
          while @line
            WHITE_AT_BEGINNING_RX__ =~ @line or break
            @fly.extra_line_a.push @line
            @line = @line_producer.gets
          end
          nil
        end

        CONTENT_START_INDEX__ = Models::Identifier::CONTENT_START_INDEX
        ID_RX__ = Models::Identifier::FORMAL_RX
        WHITE_RX__ = /[ \t]+/
        WHITE_AT_BEGINNING_RX__ = /\A#{ WHITE_RX__.source }/
      end
    end
  end
end
