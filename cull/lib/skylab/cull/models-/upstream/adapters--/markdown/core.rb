module Skylab::Cull

  module Models_::Upstream

    class Adapters__::Markdown < Here_::FileBasedAdapter_

      EXTENSIONS = %w( .md .markdown )

      class << self

        def via_table_number_and_path d, path, & p
          new d, path, & p
        end
      end

      def initialize d=nil, path, & p
        @table_number = d
        super path, & p
      end

      def to_descriptive_event  # (or `to_event`)

        me = self
        Build_event_.call(
          :markdown_upstream,
          :path, @path,
          :ok, true,
        ) do |y, _o|
          y << me.describe_entity_under_( self )
        end
      end

      def describe_entity_under_ expag
        path = @path
        expag.calculate do
          "markdown file: #{ pth path }"
        end
      end

      def adapter_symbol
        :markdown
      end

      def to_entity_stream
        entity_stream_at_some_table_number @table_number || 1
      end

      def to_entity_stream_stream

        @line_stream = Home_.lib_.system.filesystem.line_stream_via_path @path

        Me___::Table_scanner_via_line_stream__[ @line_stream, & @_emit ]
      end

      def event_for_fell_short_of_count wanted_number, had_number

        Build_not_OK_event_.call(
          :early_end_of_stream,
          :byte_stream_reference, @line_stream.to_byte_stream_reference,
          :wanted_number, wanted_number,
          :had_number, had_number,
        ) do |y, o|

          want = o.wanted_number
          had = o.had_number

          _msg = if had.zero? and 1 == want
            "there were no markdown tables anywhere before #{
             }end of stream"
          else
            "needed #{ want } but had#{
              if had.zero?
                " no"
              else
                " only #{ had }"
              end
             } markdown table#{ s had } in the entirety of the input"
          end

          y << "early end of stream - #{ _msg } of #{
           }#{ o.byte_stream_reference.description_under self }."
        end
      end

      Me___ = self
    end
  end
end
