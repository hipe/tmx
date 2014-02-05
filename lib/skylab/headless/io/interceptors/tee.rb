module Skylab::Headless

  IO::Interceptors::Tee = Headless::Library_::MetaHell::Proxy::Tee.new(
    :<<,
    :close,
    :closed?,
    :puts,
    :read,
    :rewind,                      # not all IO have this, us at own risk
    :truncate,                    # idem
    :write ) do

    # Inspired by (but probably not that similar to) Perl's IO::Tee,
    # an IO::Interceptors::Tee is a simple multiplexer that intercepts
    # and multiplexes out a subset of the messages that an ::IO stream
    # receives.
    #
    # Tee represents its downstream listeners as (effectively) elements
    # of an ordered hash; that is, the order in which they were added is
    # remembered and they are retrieved by their key, usually a symbol.
    # (we refer to this structure as a "box".)

    -> do
      kls = self
      define_method :respond_to? do |m|
        kls.method_names.include? m.intern
      end
    end.call

    def nil?
      false
    end
  end

  class IO::Interceptors::Tee

    include (( module Is_TTY_Instance_Methods
      # Mock whether or not this stream is an interactive terminal (see `IO#tty?`)

      def tty!
        @is_tty = true
        self
      end

      attr_accessor :is_tty

      alias_method :tty?, :is_tty

      self
    end ))
  end
end
