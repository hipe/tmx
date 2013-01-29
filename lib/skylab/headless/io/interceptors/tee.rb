module Skylab::Headless

  class IO::Interceptors::Tee < MetaHell::Proxy::Tee.new(
    :<<,
    :puts,
    :rewind,                      # not all IO have this, us at own risk
    :truncate,                    # idem
    :write )

    # Inspired by (but probably not that similar to) Perl's IO::Tee,
    # an IO::Interceptors::Tee is a simple multiplexer that intercepts
    # and multiplexes out a subset of the messages that an ::IO stream
    # receives.
    #
    # Tee represents its downstream listeners as (effectively) elements
    # of an ordered hash; that is, they are ordered and can be referenced
    # by their symbol (this is called a "Box" around these parts).

    include Headless::IO::Interceptor::InstanceMethods
  end
end
