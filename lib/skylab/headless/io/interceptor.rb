module Skylab::Headless
  module IO::Interceptor end
  module IO::Interceptor::InstanceMethods
    # Mock whether or not this stream is an interactive terminal (see `IO#tty?`)
    attr_accessor :tty
    def tty!    ; self.tty = true  ; self end
    def no_tty! ; self.tty = false ; self end
    alias_method :tty?, :tty  # compat with (look like) ::IO
  end
end
