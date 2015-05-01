module Skylab::Headless

  module IO

    class << self

      def dry_stub
        IO::Dry_Stub__
      end

      def dry_stub_instance
        IO::DRY_STUB__
      end

      def line_stream io, num_bytes=nil
        IO_::Line_Scanner__.new io, num_bytes
      end

      def select
        IO_::Select__
      end
    end

    Byte_Identifer_ = ::Class.new

    class Byte_Downstream_Identifier < Byte_Identifer_

      # :+( near [#br-019] )

      # ~ reflection

      def fallback_description_
        "«output stream»"  # :+#guillemets
      end

      def EN_preposition_lexeme
        'to'
      end

      # ~ data acceptance exposures

      def to_minimal_yielder
        @io
      end
    end

    class Byte_Identifer_

      # (see subclasses)

      def initialize io
        @io = io
      end

      # ~ reflection

      def is_same_waypoint_as x
        if :IO == x.shape_symbol
          io = __the_IO
          if @io.fileno == io.fileno
            true
          elsif @io.respond_to?( :path ) && io.respond_to?( :path )
            @io.path == io.path  # not as normal as it could be
          end
        end
      end

      protected def __the_IO
        @io
      end

      def description_under expag
        if @io.respond_to? :path
          path = @io.path
          expag.calculate do
            pth path
          end
        else
          fallback_description_
        end
      end

      def shape_symbol
        :IO
      end

      def modality_const
        :Byte_Stream
      end
    end

    MAXLEN_ = 4096  # ( 2 ** 12), or the number of bytes in about 50 lines

    METHOD_I_A_ = [
      :<<,
      :close,
      :closed?,
      :puts,
      :read,
      :rewind,  # not all IO have this, us at own risk
      :truncate,  # idem
      :write
    ].freeze

    IO_ = self
  end
end
