module Skylab::TestSupport

  class IO::Spy__::Group__  # read the related [#023] IO spy composite..narrative

    def initialize

      @debug = @debug_IO = nil
      @line_a = []
      @line_map_p_a = nil
      @k_a = []
      @stream_h = {}
    end

    def freeze
      @line_a.freeze
      a = @line_map_p_a
      a and a.freeze
      @k_a.freeze
      @stream_h = :__DONE__
      super
    end

    def dup  # for [#.A] "frame techinque"
      a = @line_a
      if ! a.frozen?
        a = a.dup
      end
      Mutable_Dup___.new a
    end

    class Mutable_Dup___
      def initialize a
        @line_a = a
      end
      def release_lines
        remove_instance_variable :@line_a
      end
    end

    attr_reader :debug
    attr_writer :debug_IO, :line_a  # hax

    def flush_to_strings_for * syms

      out_h = ::Hash[ syms.map { | sym | [ sym, "" ] } ]

      @line_a.each do | line |

        s = out_h[ line.stream_symbol ]
        if s
          s.concat line.string
        end
      end
      @line_a = nil
      syms.map { | sym | out_h.fetch sym }
    end

    def flush_to_line_stream_on sym  # lines as strings, not as objects

      a = @line_a
      @line_a = nil
      Common_::Stream.via_nonsparse_array( a ).map_reduce_by do | line_o |

        if sym == line_o.stream_symbol
          line_o.string
        end
      end
    end

    def lines
      @line_a
    end

    def release_lines

      @line_a or raise "lines already released"
      x = @line_a
      @line_a = @stream_h = nil
      x
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

    def add_strm_with_name_and_value name_x, x
      did = false
      @stream_h.fetch name_x do
        did = true
        @k_a << name_x
        @stream_h[ name_x ] = x
      end
      did or raise "constituent is write-once: '#{ name_x }'"
      x
    end

  private

    def build_spy_for name_x, & init_p

      downstream_IO = Home_::Library_::StringIO.new

      _line_end_proc = -> do

        downstream_IO.rewind

        s = downstream_IO.string.dup  # you gotta

        downstream_IO.truncate 0

        if @line_map_p_a
          s = @line_map_p_a.reduce s do | x, p |
            p[ x ]
          end
        end

        line = Line___.new name_x, s

        if @debug and @debug.condition_p[]
          @debug.emit_line_p[ line ]
        end

        @line_a.push line
        NIL_
      end

      _filter = Home_.lib_.system_lib::IO::Mappers::Filter.with(
        :downstream_IO, downstream_IO,
        :line_end_proc, _line_end_proc,
      )

      spy = IO.spy :nonstandard
      spy[ :line_emitter ] = _filter
      if init_p
        init_p[ spy ]
      end
      spy
    end

    class Line___  # #[#007.1]

      def initialize stream_symbol, string
        @stream_symbol = stream_symbol
        @string = string
      end

      def to_a
        [ @stream_symbol, @string ]
      end

      attr_reader(
        :stream_symbol,
        :string,
      )
    end

  public

    def do_debug
      @debug && @debug.condition_p[]
    end

    def do_debug_proc= p

      @debug ||= Debug__.new
      @debug.condition_p = p

      if ! @debug.emit_line_p
        _engage_debugging some_debug_IO
      end
      p
    end

    def some_debug_IO
      @debug_IO || Home_.lib_.stderr
    end

    def _engage_debugging stderr  # each time a line is parsed out of any stream we will
      # `puts` to your `stderr` a line in a format of our choosing showing
      # both the stream name and the string content after any filters have
      # been applied
      @debug ||= Debug__.new
      @debug.condition_p ||= MONADIC_TRUTH_
      @debug.emit_line_p = -> line do
        stderr.puts [ line.stream_symbol, line.string ].inspect
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
        name_i_a << o.stream_symbol
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
        @stream_name_hash.fetch struct.stream_symbol do |k|
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
