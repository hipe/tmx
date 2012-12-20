module Skylab::Headless

  class IO::Interceptors::Tee < ::Struct.new :downstreams

    # Inspired by (but probably not that similar to) Perl's IO::Tee,
    # an IO::Interceptors::Tee is a simple multiplexer that intercepts
    # and multiplexes out a subset of the messages that an ::IO stream
    # receives.
    #
    # Tee represents its downstream listeners as (effectively) elements
    # of an ordered hash; that is, they are ordered and can be referenced
    # by their symbol.


    include Headless::IO::Interceptor::InstanceMethods

    [:<<,
     :puts,
     :rewind,                     # not all IO have this, us at own risk
     :truncate,                   # idem
     :write
    ].each do |m|
      define_method m do |*a, &b|
        downstreams.each { |o| o.send(m, *a, &b) }
      end
    end

    def [] key # #gigo
      downstreams[@hash[key]]
    end

    def []= key, value
      downstreams[@hash[key] ||= downstreams.length] = value
    end

    def has? k
      @hash.key? k
    end

  protected

    def initialize downstreams_h=nil
      super []
      @hash = { }
      downstreams_h and downstreams_h.each { |k, v| self[k] = v }
    end
  end
end
