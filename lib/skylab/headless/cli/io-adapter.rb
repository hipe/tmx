module Skylab::Headless

  module CLI::IO_Adapter
  end

  class CLI::IO_Adapter::Minimal

    # a note about names - here we do *not* observe the PIE convention
    # [#sl-113] for the names of these three streams: the PIE convention
    # is a higher-level event-y concern that assigns semantic associations
    # to the different streams. down here, we just want symbolic names that
    # reference the actual three streams (whatever they actually are) that
    # are used in the POSIX standard way of having a standard in, standard
    # out, and standard error stream.

    def initialize sin, sout, serr, pen=CLI::Pen::MINIMAL
      # per edict [#sl-114] we keep explicit mentions of the streams out at
      # this level -- they can be nightmarish to adapt otherwise.
      @instream, @outstream, @errstream, @pen = sin, sout, serr, pen ; nil
    end

    attr_reader :instream, :outstream, :errstream, :pen

    attr_writer :instream  # it gets modified from the cli client s/times

    def to_two
      [ @outstream, @errstream ]
    end

    def to_three
      [ @instream, @outstream, @errstream ]
    end

    def emit type_i, msg
      # life is easier with this behavior written-in as a default.
      instance_variable_get( :payload == type_i ? :@outstream : :@errstream ).
        puts msg ; nil
    end
  end
end
