module Skylab::Snag

  class Models::Manifest::File__  # see [#038], intro at #note-12

    def initialize pathname
      @file_mutex = false
      @fh = nil
      @pathname = pathname
    end

    attr_reader :pathname

    def is_open  # #note-52
      @file_mutex
    end

    def normalized_lines  # #note-42
      if block_given?
        scn = normalized_line_producer ; x = nil
        begin
          while x = scn.gets
            yield x
          end
          x
        ensure
          @file_mutex and stop_self
        end
      else
        to_enum :normalized_lines
      end
    end

    def normalized_line_producer
      @nlp ||= bld_normalized_line_producer
    end

  private

    def bld_normalized_line_producer
      line_number = 0
      p = -> do
        start
        p = -> do
          if @file_mutex
            line = @fh.gets
            if line
              line_number += 1
              line.chomp!
              line
            else
              stop_self
              nil
            end
          end
        end
        p[]
      end
      Normalized_Line_Producer__.new do |o|
        o.stop_p = method :stop_requested_from_line_producer
        o.pathname = @pathname
        o.line_number_p = -> { line_number }
        o.gets_p = -> { p[] }
      end
    end

    def start
      @file_mutex and self._ALREADY_STARTED
      @fh = @pathname.open 'r'  # #open-filehandle, #gigo
      @file_mutex = true ; nil
    end

    def stop_requested_from_line_producer
      if @file_mutex  # see #note-72
        stop_self
      end
    end

    def stop_self
      @file_mutex = nil
      @fh.close
      @fh = @nlp = nil
    end

    class Normalized_Line_Producer__
      def initialize
        yield self ; freeze
      end
      attr_accessor :pathname
      attr_writer :gets_p, :line_number_p, :stop_p
      def line_number
        @line_number_p.call
      end
      def gets
        @gets_p.call
      end
      def stop
        @stop_p.call
      end
    end
  end
end
