module Skylab::TestSupport

  class IO::Spy__::Group__  # read the related [#023] IO spy composite..narrative

    def initialize
      @debug = @debug_IO = nil
      @line_a = [ ] ; @line_map_p_a = nil
      @k_a = [] ; @stream_h = { } ; nil
    end

    attr_reader :debug
    attr_writer :debug_IO

    def lines
      @line_a
    end

    def release_lines
      @line_a or raise "lines already released"
      r = @line_a ; @line_a = @stream_h = nil ; r
    end

    def keys
      @k_a.dup
    end

    def to_a
      values_at( * @k_a )
    end

    def values_at * k_a
      k_a.map do |k|
        @stream_h.fetch k
      end
    end

    def [] k
      @stream_h.fetch k
    end

    def for name_x
      @stream_h.fetch name_x do
        @k_a << name_x
        @stream_h[ name_x ] = build_spy_for name_x
      end
    end

    def add_stream name_x, * a, & init_p
      case a.length <=> 1
      when -1 ; add_stream_with_name_and_init_p name_x, init_p
      else    ; add_strm_with_name_and_value name_x, * a end
    end

    def add_stream_with_name_and_init_p name_x, init_p
      _stream = build_spy_for name_x, & init_p
      add_strm_with_name_and_value name_x, _stream
    end

    def add_strm_with_name_and_value name_x, value_x
      did = false
      @stream_h.fetch name_x do
        did = true
        @k_a << name_x
        @stream_h[ name_x ] = value_x
      end
      did or raise "constituent is write-once: '#{ name_x }'" ; nil
    end

  private

    def build_spy_for name_x, & init_p

      downstream_IO = TestSupport_::Library_::StringIO.new

      _filter = TestSupport_._lib.IO::Mappers::Filter.new(
        :downstream_IO, downstream_IO,
        :line_end_proc, -> do
          downstream_IO.rewind
          s = downstream_IO.string.dup  # you gotta
          downstream_IO.truncate 0
          @line_map_p_a and s = @line_map_p_a.reduce( s ) { |x, p| p[x] }
          line = Line__.new name_x, s
          if @debug and @debug.condition_p[]
            @debug.emit_line_p[ line ]
          end
          @line_a.push line ; nil
        end )

      spy = IO.spy :nonstandard
      spy[ :line_emitter ] = _filter
      init_p and init_p[ spy ]
      spy
    end
    #
    class Line__  # :+[#ts-007]
      def initialize stream_name, string
        @stream_name = stream_name ; @string = string
      end
      attr_reader :stream_name, :string
      alias_method :channel_x, :stream_name
      def payload_x
        @string.chop
      end
      def to_a
        [ @stream_name, @string ]
      end
    end

  public

    def do_debug
      @debug && @debug.condition_p[]
    end

    def do_debug_proc= p
      @debug ||= Debug__.new
      @debug.condition_p = p
      @debug.emit_line_p or debug! some_debug_IO
      p
    end

    def some_debug_IO
      @debug_IO || TestSupport_._lib.stderr
    end

    def debug! stderr  # each time a line is parsed out of any stream we will
      # `puts` to your `stderr` a line in a format of our choosing showing
      # both the stream name and the string content after any filters have
      # been applied
      @debug ||= Debug__.new
      @debug.condition_p ||= MONADIC_TRUTH_
      @debug.emit_line_p = -> line do
        stderr.puts [ line.stream_name, line.string ].inspect
      end
      stderr
    end
    #
    Debug__ = ::Struct.new :condition_p, :emit_line_p

    def add_line_map_proc p  # when a line is resolved to be added to '@line_a'
      # send the string to all such 'p' in the order they were received
      # in a reduce operation such that each next 'p' receives the result of
      # the previous 'p'. the final result will be added to '@line_a'.
      ( @line_map_p_a ||= [] ).push p
    end

    def unzip  # goofy fun. result: 2 parallel arrays: names and strings
      r = Names_And_Strings__.new 2
      name_i_a = r[ 0 ] = [ ] ; string_a = r[ 1 ] = [ ]
      @line_a.each do |o|
        name_i_a << o.stream_name
        string_a << o.string
      end
      r
    end
    class Names_And_Strings__ < ::Array
      def names   ; self[ 0 ] end
      def strings ; self[ 1 ] end
    end

    class Composite  # :+#public-API

      def self.of enum
        me = new
        enum.each do |emission|
          me.see emission
        end
        me.to_read_only
      end

      def initialize
        @unique_stream_name_order_i_a = [ ]
        @stream_name_hash = { }
        @text_a = [ ]
      end

      def see struct
        @stream_name_hash.fetch struct.stream_name do |k|
          @stream_name_hash[k] = true
          @unique_stream_name_order_i_a << k
        end
        @text_a << struct.string
        nil
      end

      def to_read_only
        Read_Only__.new @unique_stream_name_order_i_a, @text_a
      end

      class Read_Only__

        def initialize unique_stream_name_order_i_a, text_a
          @unique_stream_name_order_i_a, @text_a =
            unique_stream_name_order_i_a.dup.freeze, text_a.dup.freeze
        end

        attr_reader :unique_stream_name_order_i_a

        def full_text
          @full_text ||= @text_a.join EMPTY_S_  # remember we didn't chomp anything!
        end
      end
    end
  end
end
