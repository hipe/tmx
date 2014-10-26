module Skylab::Headless

  module IO

    class << self

      def dry_stub_instance
        IO::DRY_STUB__
      end

      def line_scanner io, num_bytes=nil
        IO_::Line_Scanner__.new io, num_bytes
      end

      def select
        IO_::Select__
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
