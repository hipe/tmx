require_relative 'test-support'

module Skylab::Brazen

  module TestSupport

    module Zerk::Expect_Interactive

      class << self

        def [] test_context_class
          test_context_class.include self
        end
      end

      def start_interactive_session chdir_path
        @session = Session__.new( self, chdir_path, interactive_bin_path ).start
        nil
      end

      def expect_screen_ending_with x
        each_chunk_until x
      end

      # ~ for parsing whole screen at once

      def in_screen_ending_with x
        s = read_screen_ending_with x
        s and begin
          @screen = s
          x = yield
          @screen = nil
          x
        end
      end

      def expect_string matcher_x
        expect_string_ends_with_matcher @screen, matcher_x
        nil
      end

      # ~ for getting a line-by-line stream in a block

      def in_lines_of_screen_ending_with x
        yield build_line_stream_for_screen_ending_with x
      end

      # ~ for parsing screen line-by-line

      def flush_to_lines_screen_ending_with x
        @lines = build_line_stream_for_screen_ending_with x
        nil
      end

      def after_any_blanks_expect_line rx
        skip_any_blank_lines
        line = @lines.gets_one
        if rx.respond_to? :named_captures
          if rx !~ line
            line.should match rx
            fail
          end
        elsif rx != line
          line.should eql rx
          fail
        end
      end

      def skip_any_blank_lines
        while @lines.unparsed_exists && BLANK_RX_ =~ @lines.current_token
          @lines.advance_one
        end
      end

      def expect_blank_line
        line = @lines.gets_one
        if BLANK_RX_ !~ line
          fail "expected blank line had: #{ line.inspect }"
        end
      end

      def expect_several_more_lines
        if @lines.unparsed_count < SEVERAL__
          fail "expected at least #{ SEVERAL__ } more lines, had #{ @lines.unparsed_count }"
        end
      end

      SEVERAL__ = 3

      # ~ common support for above

      def build_line_stream_for_screen_ending_with x
        screen = read_screen_ending_with x
        screen and begin
          Callback_::Polymorphic_Stream.via_array screen.split( LINE_DELIM_RX__ )  # or we MIGHT switch it to a stream
        end
      end

      def read_screen_ending_with x
        chunks = []
        ok = each_chunk_until x do |s|
          chunks.push s
        end
        ok and chunks.join EMPTY_S_
      end

      def each_chunk_until stop_string

        tail_range = - stop_string.length.nonzero? .. -1
        timeout = READ_TIMEOUT_SECONDS__

        begin
          r, w, e = ::IO.select [ @session.err ], nil, nil, timeout
          r or break
          w.length.zero? && e.length.zero? or self._LOOK
          chunk = r.first.read_nonblock READ_BYTES__

          yield chunk if block_given?

          if stop_string == chunk[ tail_range ]
            did_find = true
            break
          end
        end while true

        if did_find
          ACHIEVED_
        else
          fail "in #{ timeout } seconds did not find `stop_string` #{
            }#{ stop_string.inspect } (had: #{ chunk.inspect })"
        end
      end

      def expect_string_ends_with_matcher screen, matcher_x
        if matcher_x.respond_to? :named_captures
          if matcher_x !~ screen
            screen.should match matcher_x
            fail
          end
        else
          actual = screen[ - matcher_x.length .. -1 ]
          if actual != matcher_x
            actual.should eql matcher_x
            fail
          end
        end
        nil
      end

      class Session__

        def initialize test_context, chdir_path, bin_path
          @bin_path = bin_path
          @chdir_path = chdir_path
          @ok = true
          @test_context = test_context
        end

        attr_reader :err

        def start
          @in, @out, @err, @thread = Brazen_::LIB_.open3.popen3 @bin_path,
            chdir: @chdir_path
          self
        end

        def puts line
          if @ok
            @in.puts line
            nil
          end
        end

        def gets
          if @ok
            @err.gets
          end
        end

        def expect_line_eventually rx  # if this complexifies use [#ts-038]
          if @ok
            do_expect_line_eventually rx
          end
        end

        def do_expect_line_eventually rx
          found = false
          count = 0
          while line = @err.gets
            count += 1
            if rx =~ line
              found = true
              break
            end
          end
          if ! found
            @ok = false
            raise "never found line in #{ count } lines,\n#{ rx.inspect }\nlast line: #{ line.inspect }"
          end
        end

        def close
          @out.close
          @err.close
        end
      end

      BLANK_RX_ = Brazen_::Zerk::BLANK_RX_

      LINE_DELIM_RX__ = /(?<=\n)/

      READ_BYTES__ = 8000  # like 100-ish lines - enough for now

      READ_TIMEOUT_SECONDS__ = 1.0

    end
  end
end
