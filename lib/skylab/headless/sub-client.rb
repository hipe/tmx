module Skylab::Headless

  module SubClient
    # this used to be more complicated, but you see what it has become now
  end


  module SubClient::InstanceMethods

  protected

    def initialize request_client # this is the heart of it all [#004]
      _sub_client_init! request_client
    end

    def actual_parameters         # not all stacks use this, just convenience
      request_client.send :actual_parameters
    end

    def emit *a
      request_client.send :emit, *a
    end

    def error s
      request_client.send :error, s
    end

    def io_adapter                # sometimes sub-clients need access to
      request_client.send :io_adapter # the streams, e.g. the instream
    end

    def info s
      request_client.send :info, s
    end

    def pen
      request_client.send :pen
    end

    attr_accessor :request_runtime # the center of [#005]
    alias_method :request_client, :request_runtime # one day!!

    def _sub_client_init! request_client
      self.request_runtime = request_client
    end

    # --- * ---

    def em s ; pen.em s end

    def human_escape s ; pen.human_escape s end

    def kbd s ; pen.kbd s end

    def parameter_label x ; pen.parameter_label x end

    # --- * ---

    THE_ENGLISH_LANGUAGE = # goes away at [#003]
      { a: ['a '], an: ['an '], is: ['is', 'are'], s:[nil, 's'] }

    def and_ a, last = ' and ', sep = ', '
      @_coun = ::Fixnum === a ? a : a.length
      (hsh = Hash.new(sep))[a.length - 1] = last
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end

    def s count=nil, part=nil
      args = [count, part].compact
      part = ::Symbol === args.last ? args.pop : :s
      coun = 1 == args.length ? args.pop : @_coun
      @_coun = ::Fixnum === coun ? coun : coun.length # gigo
      THE_ENGLISH_LANGUAGE[part][1 == @_coun ? 0 : 1]
    end
  end
end
