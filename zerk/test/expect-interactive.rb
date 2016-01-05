module Skylab::Zerk::TestSupport

  module Expect_Interactive  # #todo-next sunset this

    PUBLIC = true

    class << self

      def [] tcc
        tcc.include Instance_Methods___
        NIL_
      end
    end  # >>

    module Instance_Methods___

      def start_interactive_session chdir_path

        sess = Sessions_::Main.new(
          self,
          chdir_path,
          self.interactive_bin_path
        )

        @interactive_session = sess  # name is :+#public-API
        sess.start

        NIL_
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

      def each_chunk_until stop_string, & when_chunk

        o = Sessions_::Nonblock.new

        if self.do_debug
          o.debug_chunk_by do | chunk |
            debug_IO.puts "(chunk: #{ chunk.inspect })"
          end
        end

        o.io = @interactive_session.err
        o.stop_string = stop_string
        o.when_chunk = when_chunk
        o.execute
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
    end
    # ->

      Sessions_ = ::Module
      class Sessions_::Main

        def initialize test_context, chdir_path, bin_path

          @bin_path = bin_path
          @chdir_path = chdir_path
          @ok = true
          @test_context = test_context
        end

        attr_reader :err

        def start
          @in, @out, @err, @thread = Home_.lib_.open_3.popen3 @bin_path,
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

      class Sessions_::Nonblock

        # read from the IO until some expected string is encountered,
        # anticipating that the IO may have no more bytes to be read before
        # that string is encountered. (select(2) is used).

        def initialize

          @timeout = READ_TIMEOUT_SECONDS__
        end

        attr_writer(
          :io,
          :stop_string,
          :when_chunk,
        )

        def debug_chunk_by & p
          @debug_chunk = p
        end

        def execute

          @when_chunk ||= MONADIC_EMPTINESS_
          @debug_chunk ||= MONADIC_EMPTINESS_

          tail_range = - @stop_string.length.nonzero? .. -1

          begin

            r, w, e = ::IO.select [ @io ], nil, nil, @timeout

            r or break

            w.length.zero? or self._COVER_ME
            e.length.zero? or self._COVER_ME
            io = r.fetch 0
            io.object_id == @io.object_id or self._SANITY

            chunk = begin
              io.read_nonblock READ_BYTES___
            rescue ::EOFError => _EOF_error
              break
            end

            @_first_chunk ||= chunk

            @debug_chunk[ chunk ]
            @when_chunk[ chunk ]

            if @stop_string == chunk[ tail_range ]
              did_find = true
              break
            end

            redo
          end while nil

          if did_find
            ACHIEVED_

          elsif _EOF_error
            fail __say_EOF _EOF_error
          else
            fail __say_not_found chunk
          end
        end

        def __say_EOF _EOF_error

          "#{ _EOF_error.message } #{
            }#{ _say_before_encountering :first, @_first_chunk }"
        end

        def __say_not_found chunk

          "timeout of #{ @timeout } seconds expired #{
           }#{ _say_before_encountering :last, chunk }"
        end

        def _say_before_encountering sym, chunk

          "before encountering #{
           }stop string: #{ @stop_string.inspect } } #{
            }(#{ sym } chunk: #{ chunk.inspect })"
        end
      end
      # <-

    ACHIEVED_ = true
    BLANK_RX_ = /\A[[:space:]]*\z/
    EMPTY_S_ = ''
    LINE_DELIM_RX__ = /(?<=\n)/
    READ_BYTES___ = 8000  # like 100-ish lines - enough for now
    READ_TIMEOUT_SECONDS__ = 1.0

  end
end
