module Skylab::Cull

  class Models_::Upstream

    class Adapters__::Markdown < Upstream_::File_Based_Adapter_

      EXTENSIONS = %w( .md .markdown )

      class << self

        def via_table_number_and_path d, path, & oes_p
          new d, path, & oes_p
        end
      end

      def initialize d=nil, path, & oes_p
        @table_number = d
        super path, & oes_p
      end

      def to_descriptive_event
        build_event_with(
            :markdown_upstream,
            :path, @path,
            :ok, true ) do | y, o |

          y << "markdown file: #{ pth o.path }"
        end
      end

      def adapter_symbol
        :markdown
      end

      def to_entity_stream
        entity_stream_at_some_table_number @table_number || 1
      end

      def to_entity_stream_stream

        @line_stream = Cull_.lib_.filesystem.line_stream_via_path @path

        Self_::Table_scanner_via_line_stream__[ @line_stream, & @on_event_selectively ]
      end

      def event_for_fell_short_of_count wanted_number, had_number

        build_not_OK_event_with :early_end_of_stream,
            :stream_identifier, @line_stream.to_identifier,
            :wanted_number, wanted_number,
            :had_number, had_number do | y, o |

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
           }#{ o.stream_identifier.description_under self }."
        end
      end

      Self_ = self
    end
  end
end
