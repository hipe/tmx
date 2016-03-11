module Skylab::Basic

  module Yielder

    class Mapper  # :[#056].

      # see also [#hu-047] for a stream version
      # see also [#hu-053] for more complex version

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
        :y,
      )
    end

    class LineFlusher < ::Enumerator::Yielder

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize y, & p

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
