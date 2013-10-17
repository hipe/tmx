module Skylab::TestSupport

  # (see also the comparable but simpler TestSupport::IO::Spy::Triad
  # which may be a good fit for testing specifically CLI apps)

  # manages a group of special stream spies, creating each one in turn with
  # `stream_spy_for` with a name you choose for each stream spy.
  # When any of those stream-likes gets written to (with `<<`, `write`, `puts`,
  # e.g) and that data has a newline in it, this puppy will create a "line"
  # metadata struct out of the line which simply groups the name you chose
  # and the string (the struct hence has the members `stream_name` and `string`).
  #
  # (If you have added line filter(s) with `line_filter!`, this will be
  # applied to the string before creating the metadata struct out of it.
  # This might be used e.g. for unstylizing lines during testing.)
  #
  # With this struct all that this Group object does is push it onto its
  # `lines` attribute for later perusal by the client.
  #
  # So effectively what this gets you is that it chunks the stream of data
  # into "lines", writes these lines sequentially in the order received to
  # one centralized list / queue / stack.  **NOTE** dangling writes without
  # a trailing newline will not yet be flushed to the queue and hence
  # not reflected in the `lines` list.  flushing could be provided if
  # necessary.)
  #
  # This is all just the ostensibly necessarily convoluted way that
  # we spoof a stdout and stderr for testing

  class IO::Spy::Group

    def keys
      @streams.keys
    end

    def debug! stderr
      # each time a line is parsed out  of any stream we will `puts` to your
      # `stderr` a line in a  format of our choosing showing both the stream
      # name and the string content after any filters have been applied
      @debug ||= Debug__.new
      @debug[:condition] ||= MetaHell::MONADIC_TRUTH_
      @debug[:emit] = -> line do
        stderr.puts [ line.stream_name, line.string ].inspect
      end
      stderr
    end
    #
    Debug__ = ::Struct.new :condition, :emit

    attr_reader :debug                         # (some tests want to know)

    def debug= p  # #todo rename
      @debug ||= Debug__.new
      @debug[:condition] = p
      debug!( Stderr_[] ) if ! @debug[:emit]
      p
    end

    def do_debug
      @debug && @debug.condition[ ]
    end

    def line_filter! f            # when a line is created to be added to
      ( @line_filters ||= [] ).push f  # `lines`, these filters will be applied
    end                           # in the order received in a reduce operation
                                  # on the string, the line having the result.
    attr_reader :lines

    def stream_spy_for name
      @streams.fetch name do
        downstream = Subsys::Services::StringIO.new
        filter = Headless::IO::Interceptors::Filter.new downstream
        filter.line_end = -> do
          downstream.rewind
          str = downstream.string.dup # you gotta
          downstream.truncate 0
          @line_filters and str = @line_filters.reduce( str ) { |x, f| f[x] }
          line = Line__.new name, str
          if @debug and @debug.condition[ ]
            @debug.emit[ line ]
          end
          @lines.push line
          nil
        end
        spy = IO::Spy.new # not a standard one! we do things differently
        spy[:line_emitter] = filter # `line_emitter` the name is insignificant
        @streams[name] = spy
        spy
      end
    end
    #
    Line__ = ::Struct.new :stream_name, :string # #duplicated at [#ts-007]

    def for *a                    # (i don't generally like aliases for aliases'
      stream_spy_for(* a)         # sake  but this one in particular can help
    end                           # make tests concise and readable)

    def unzip  # goofy fun. result: 2 parallel arrays: names and strings
      r = Names_And_Strings__.new 2
      name_i_a = r[ 0 ] = [ ] ; string_a = r[ 1 ] = [ ]
      lines.each do |o|
        name_i_a << o.stream_name
        string_a << o.string
      end
      r
    end
    class Names_And_Strings__ < ::Array
      def names   ; self[ 0 ] end
      def strings ; self[ 1 ] end
    end

  private

    def initialize
      @debug = nil
      @line_filters = nil
      @lines = [ ]
      @streams = { }
    end
  end


  class IO::Spy::Group::Composite

    def self.of enum
      me = new
      enum.each do |emission|
        me.see emission
      end
      me.to_read_only
    end

    def see struct
      @stream_name_hash.fetch struct.stream_name do |k|
        @stream_name_hash[k] = true
        @unique_stream_name_order << k
      end
      @text_a << struct.string
      nil
    end

    def to_read_only
      ReadOnly.new @unique_stream_name_order, @text_a
    end

    def initialize
      @unique_stream_name_order = [ ]
      @stream_name_hash = { }
      @text_a = [ ]
    end
  end

  class IO::Spy::Group::Composite::ReadOnly

    def full_text
      @full_text ||= @text_a.join ''  # remember we didn't chomp anything!
    end

    attr_reader :unique_stream_name_order

    def initialize unique_stream_name_order, text_a
      @unique_stream_name_order, @text_a =
        unique_stream_name_order.dup.freeze, text_a.dup.freeze
    end
  end
end
