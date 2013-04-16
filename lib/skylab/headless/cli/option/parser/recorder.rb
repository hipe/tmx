module Skylab::Headless

  class CLI::Option::Parser::Recorder

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

    def initialize &emit_option
      define_singleton_method :define do |*a, &b|
        emit_option[ CLI::Option.on( *a, &b ) ]
        # result is undefined for now, but could be changed if needed
        nil
      end
    end

    def on *a, &b
      self.define( *a, &b )
      self
    end
  end
end
