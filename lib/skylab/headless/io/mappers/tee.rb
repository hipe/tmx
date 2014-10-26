module Skylab::Headless

  module IO

  module Mappers

  Tee = Headless_::Lib_::Proxy_lib[].tee.via_arglist IO_::METHOD_I_A_  # :[#169].

    # Inspired by (but probably not that similar to) Perl's IO::Tee,
    # an IO::Mappers::Tee is a simple multiplexer that intercepts
    # and multiplexes out a subset of the messages that an ::IO stream
    # receives.
    #
    # Tee represents its downstream listeners as (effectively) elements
    # of an ordered hash; that is, the order in which they were added is
    # remembered and they are retrieved by their key, usually a symbol.
    # (we refer to this structure as a "box".)

  class Tee

    include( module Is_TTY_Instance_Methods
      # Mock whether or not this stream is an interactive terminal (see `IO#tty?`)

      def tty!
        @is_tty = true
        self
      end

      attr_accessor :is_tty

      alias_method :tty?, :is_tty

      self
    end )
  end
  end
  end
end
