module Skylab::System

  module IO  # :[#010].

    # ==

    class DownstreamProxy < Common_::SimpleModel

      # the final, favorite of many #[#039.1] similar proxies

      attr_writer(
        :byte_stream_reference,
        :listener,
      )

      def puts s=nil
        @listener[ s, :puts, @byte_stream_reference ]
        NIL
      end

      def << s
        @listener[ s, :<<, @byte_stream_reference ]
        self
      end

      def write s
        @listener[ s, :write, @byte_stream_reference ]
        s.length
      end
    end

    # ==

    # our exposures of #[#ba-062.1] & #[#ba-062.2] (see manifesto) have
    # perhaps distinct
    # characteristics when compared to other adaptations in this strain
    # owing both to our practical requirements and to characteristics of
    # IO handles themselves:
    #
    # ideally the subjects in this strain are immutable; but we are wrappng
    # an IO handle and the handle itself has state: it can be either open or
    # closed, and (when open) it has an internal read/write "cursor".
    # typically clients will be aware of this statefulness and break the
    # abstraction layer as necessary.
    #
    # also (and perhaps more significantly) we must model for the idea that
    # the IO handle we are wrapping is any of the THREE permutations of
    # readable and writable (with at least one of them being true) so
    # read-only, write-only, and read-write.
    #
    # as such we cannot simply have one class for "upstreams" and another
    # for "downstreams". (in fact it may be that the work here reflects
    # the beginning of a broader the dismantling of these deep idioms;
    # which may present a false dichotomy..)

    module ByteUpstreamReference ; class << self
      def via_open_IO io
        ByteStreamReference.define do |o|
          o.will_be_readable
          o.IO = io
        end
      end
    end ; end

    module ByteDownstreamReference ; class << self
      def via_open_IO io
        ByteStreamReference.define do |o|
          o.will_be_writable
          o.IO = io
        end
      end
    end ; end

    class ByteStreamReference < Common_::SimpleModel

      def initialize
        @_is_readable = false
        @_is_writable = false
        super
      end

      def will_be_writable
        extend ByteStreamReferenceMethodsApplicableToWritable_ONLY___
        @_is_writable = true
      end

      def will_be_readable
        extend ByteStreamReferenceMethodsApplicableToReadable_ONLY___
        @_is_readable = true
      end

      attr_writer(
        :IO,
      )

      def CLOSE_BYTE_STREAM_IO  # [tm] experiment
        @IO.close
      end

      def description_under expag
        if @IO.respond_to? :path
          path = @IO.path
          expag.calculate do
            pth path
          end
        elsif @_is_readable
          # #guillemets
          if @_is_writable
            "«input/output stream»"
          else
            "«input stream»"
          end
        elsif @_is_writable
          "«output stream»"
        else
          self._NEVER
        end
      end

      def is_same_waypoint_as otr
        if :IO == otr.shape_symbol
          io = otr.__IO
          if @IO.fileno == io.fileno
            true
          elsif @IO.respond_to?( :path ) && io.respond_to?( :path )

            self._REVIEW__easy__

            @IO.path == io.path  # see 
          end
        end
      end

      def __IO
        @IO
      end
      protected :__IO

      def path  # WHERE AVAILABLE
        @IO.path
      end

      def BYTE_STREAM_IO_FOR_LOCKING  # [sn], [tm]
        @IO
      end

      def shape_symbol
        :IO
      end

      def modality_const
        :ByteStream
      end

      def BYTE_STREAM_IO_IS_TTY  # [tm]
        @IO.tty?
      end
    end

    module ByteStreamReferenceMethodsApplicableToWritable_ONLY___

      def to_minimal_yielder_for_receiving_lines  # #[#ba-046]
        @IO.rewind
        @IO.truncate 0
        @IO
      end
    end

    module ByteStreamReferenceMethodsApplicableToReadable_ONLY___

      def to_mutable_whole_string  # (`Treetop` needs whole strings)
        @IO.read  # or whatever
      end

      alias_method :to_read_only_whole_string, :to_mutable_whole_string

      def to_minimal_line_stream
        @IO
      end

      def TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT
        @IO.rewind
        @IO
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
    # ==
  end
end
# #history-A: merged byte stream identifers (down & up) into one node
