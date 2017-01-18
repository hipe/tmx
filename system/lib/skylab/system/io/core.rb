module Skylab::System

  module IO

    class << self

      def dry_stub
        Here_::Dry_Stub__
      end

      def dry_stub_instance
        Here_::DRY_STUB__
      end

      def select
        Here_::Select__
      end
    end  # >>

    # ==

    class DownstreamProxy < SimpleModel_

      # the final, favorite of many #[#039.1] similar proxies

      attr_writer(
        :listener,
        :stream_identifier,
      )

      def puts s=nil
        @listener[ s, :puts, @stream_identifier ]
        NIL
      end
      def << s
        @listener[ s, :<<, @stream_identifier ]
        self
      end
      def write s
        @listener[ s, :write, @stream_identifier ]
        s.length
      end
    end

    # ==

    Byte_Identifer_ = ::Class.new

    class Byte_Downstream_Identifier < Byte_Identifer_   # :+[#br-019.D]

      # ~ reflection

      def fallback_description_
        "«output stream»"  # :+#guillemets
      end

      def EN_preposition_lexeme
        'to'
      end

      # ~ data acceptance exposures

      def to_minimal_yielder  # :+[#ba-046]
        @io
      end
    end

    class Byte_Identifer_

      class << self
        alias_method :new_via_open_IO, :new
        private :new
      end  # >>

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

    # ==

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

    Autoloader_[ self ]
    stowaway :Mappers, 'mappers/filter'

    # ==

    Here_ = self
    MAXLEN_ = 4096  # (2 ** 12), or the number of bytes in about 50 lines

    # ==
  end
end
