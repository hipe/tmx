module Skylab::System

  module IO

    Line_Scanner__ = Common_::Session::Ivars_with_Procs_as_Methods.new(
      :count, :gets, :lineno )

    class Line_Scanner__  # read [#164]

      def initialize fh, maxlen=nil
        maxlen ||= MAXLEN_
        buffer = ''
        buffer_is_loaded = nil
        count = 0
        gets = scn = nil
        advance_scanner = -> do
          scn = Home_.lib_.string_scanner buffer
          advance_scanner = -> do
            scn.string = buffer ; nil
          end ; nil
        end
        advance = -> do
          advance_scanner[]
          buffer = ''
          buffer_is_loaded = true
        end
        finish = -> do
          gets = EMPTY_P_
          fh.close
          false
        end
        load_buffer = -> do
          buffer_ = fh.read maxlen, buffer
          buffer_ ? advance[] : finish[]
        end
        current_line = nil
        absorb_line_part = -> part do
          if current_line
            current_line.concat part
          else
            current_line = part
          end ; nil
        end
        gets = -> do
          begin
            buffer_is_loaded or load_buffer[] or break
            line_part = scn.scan LINE_RX__
            line_part or next( buffer_is_loaded = false )
            absorb_line_part[ line_part ]
            line_part.include? NEWLINE_ and break( count += 1 )
          end while true
          r = current_line ; current_line = nil ; r
        end

        @gets = -> do
          gets[]  # we make this totally hack-proof just as an OCD experiment
        end
        # ~ auxiliary service methods
        @count = -> { count }
        @fh = fh  # in case you want to close it yourself (if from Path)
        @lineno = -> do
          count.nonzero?
        end

        @pathname = if fh.respond_to? :path
          Home_.lib_.pathname.new fh.path
        end

        NIL
      end

      attr_reader :fh, :pathname

      LINE_RX__ = Basic_[]::String.regex_for_line_scanning

      # ~

      def to_identifier
        Basic_[]::Pathname.identifier @pathname
      end
    end
  end
end
