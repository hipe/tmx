module Skylab::Headless

  class CLI::Option::Parser::Recorder < Headless::Library_::Function_Class.
    new :on, :@on, :define  # ( note this doesn't yet follow exactliy the ::OP API.. )

    # (this was written after whatever happens in treemap and that should
    # get merged into this one day..)
    #
    # It's en evented recorder - all it does is mock like it's an option
    # parser (by defining `on`) and it calls `emit_option` with each mock/
    # universal option object that each call to `on` produces.
    #
    # future features could include callbacks for `banner` and
    # `separator`..
    #
    # (see also option merge)

    def initialize &option_cb
      option_cb or raise ::ArgumentError, "missing required block."
      @on = -> *a, &b  do
        option_cb[ CLI::Option.on( *a, &b ) ]
        # result is undefined for now, but could be changed if needed
        nil
      end
    end
  end
end
