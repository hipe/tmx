module Skylab::TestSupport

  module IO  # ~ stowaway

    class << self
      def spy * a
        if a.length.zero?
          Spy__
        else
          Spy__.new( * a )
        end
      end
    end
  end

  class IO::Spy__ < Home_.lib_.system_lib::IO::Mappers::Tee  # :[#023] ..

    class << self

      def group
        Spy_::Group__
      end

      def triad * a
        if a.length.zero?
          Spy_::Triad__
        else
          Spy_::Triad__.new( * a )
        end
      end
    end

    class Shell___  # too hard to do this in a basic object

      attrs = Attributes_actor_.call( self,
        debug_IO: nil,
        debug_prefix: nil,
        do_debug_proc: nil,
        puts_map_proc: nil,
      )

      private  # ->

        def do_debug=
          @do_debug_value_was_passed = true
          @do_debug_x = gets_one
          ACHIEVED_
        end

        def nonstandard=
          @is_standard = false
          ACHIEVED_
        end

        # <-

      def initialize x_a
        @is_standard = true
        process_argument_scanner_fully scanner_via_array x_a
      end

    public

      attr_reader( * attrs.symbols )

      attr_reader :do_debug_value_was_passed, :do_debug_x, :is_standard

    end

    def initialize * x_a
      o = Shell___.new x_a
      @debug_IO = o.debug_IO
      @debug_prefix = o.debug_prefix
      @puts_map_proc = o.puts_map_proc
      @do_debug_p = o.do_debug_proc
      if o.do_debug_value_was_passed && ! @do_debug_p
        x = o.do_debug_x
        @do_debug_p = -> { x }
      end

      super()

      @this_system_IO_tee_is_a_tty = true

      if o.is_standard
        @muxer.add BUFFER_I__, Home_::Library_::StringIO.new
      end

      if @do_debug_p  # see [#023.B]
        add_debugging_downstream
      end ; nil
    end

    # ~ stringIO buffer interaction

    def string  # assumes this constituent
      self[ BUFFER_I__ ].string
    end

    def clear_buffer
      io = self[ BUFFER_I__ ]
      io.rewind
      io.truncate 0
      nil
    end

    # ~ debugging

    def add_debugging_downstream

      _downstream_IO = @debug_IO || Home_.lib_.stderr

      @debug_IO = nil

      if @debug_prefix
        _line_begin_string = @debug_prefix
        @debug_prefix = nil
      end

      if @puts_map_proc
        _puts_map_proc = @puts_map_proc
      end

      _niladic_pass_filter_proc = @do_debug_p

      _io = Home_.lib_.system_lib::IO::Mappers::Filter.with(
        :downstream_IO, _downstream_IO,
        :line_begin_string, _line_begin_string,
        :niladic_pass_filter_proc, _niladic_pass_filter_proc,
        :puts_map_proc, _puts_map_proc )

      @muxer.add DEBUG_I__, _io
      NIL_
    end

    BUFFER_I__ = :buffer
    DEBUG_I__ = :debug  # ok to open up if needed
    Spy_ = self

  end
end
