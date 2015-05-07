module Skylab::System

  module IO

    module Mappers

      module Chunkers

        class Common

          # map reduce/expand upstream chunks of data into downstream lines

          def initialize p
            @buffer = System_.lib_.string_IO.new
            @p = p
            @scn = System_.lib_.string_scanner EMPTY_S_
            @separator = NEWLINE_
            @separator_rx = /#{ ::Regexp.escape @separator }/
          end

          def write data
            @buffer.write data
            if @buffer.string.index @separator
              flush_buffer
            end
            nil
          end

          def flush  # send any remaining data. any data in the buffer got there
            # through write and so is "guaranteed" not to have newlines.
            s = flush_both
            if s.length.nonzero?
              @scn.string = EMPTY_S_
              @p[ s ]
            end
            nil
          end

        private

          def flush_buffer
            @scn.string = flush_both
            line = @scn.scan_until @separator_rx
            begin
              @p[ line ]
              line = @scn.scan_until @separator_rx
            end while line
            nil
          end

          def flush_both
            s = "#{ @scn.rest }#{ @buffer.string }"
            @buffer.rewind
            @buffer.truncate 0
            s
          end
        end
      end
    end
  end
end
