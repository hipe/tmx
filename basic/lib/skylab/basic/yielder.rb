module Skylab::Basic

  module Yielder

    class Mapper  # :[#056].

      # see also [#hu-047] for a more complex stream version

      class << self

        def joiner y, separator_s
          o = new
          o.downstream_yielder = y
          o.map_first = IDENTITY_
          o.map_subsequent_by do |s|
            "#{ separator_s }#{ s }"
          end
          o
        end
      end  # >>

      def map_first_by & p
        @map_first = p
      end

      def map_subsequent_by & p
        @map_subsequent = p
      end

      def initialize_copy _
        @y = nil
      end

      def downstream_yielder= y
        reset
        @y = ::Enumerator::Yielder.new do |x|
          send @_m, x
        end
        @downstream_yielder = y
      end

      attr_writer(
        :map_first,
      )

      def reset
        @_m = :___receive_first_item ; nil
      end

      def ___receive_first_item x
        @downstream_yielder << @map_first[ x ]
        @_m = :___receive_subsequent_item
        NIL_
      end

      def ___receive_subsequent_item x
        @downstream_yielder << @map_subsequent[ x ]
        NIL_
      end

      attr_reader(
        :downstream_yielder,
        :y,
      )
    end

    class LineFlusher < ::Enumerator::Yielder

      # a session that effects a map expand/reduce: it receives input strings
      # (of any structure) through the interface of a yielder (hence its
      # parent class); and outputs strings progressively to another yielder
      # (the argument). the bytes that will be output will be the same
      # sequence of bytes that were in the input, but they will be buffered
      # and chunked such that every item of output is a newline-sequence-
      # terminated string; except for any item output through a `flush` which
      # outputs any string in the buffer (which, if one is there does not
      # have a terminating sequence).

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize y

        scn = Home_.lib_.empty_string_scanner
        buffer = scn.string

        super() do |s|
          buffer.concat s
          begin
            line = scn.scan RX___
            line or break
            y << line
            redo
          end while nil
        end

        @__flush = -> do
          s = scn.rest
          if s.length.nonzero?
            y << s
          end
          buffer = nil ; scn = nil
          y
        end
      end

      RX___ = /[^\r\n]*(?:\r?\n|\r)/

      def flush
        @__flush[]
      end
    end

    class Byte_Downstream_Identifier  # :+[#br-019.D]

      def initialize yld

        @_yielder = yld
      end

      def to_minimal_yielder

        @_yielder
      end

      def shape_symbol

        :yielder
      end
    end
  end
end
