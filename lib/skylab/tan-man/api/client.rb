module Skylab::TanMan


  class API::Client                            # the only thing that should
                                               # have knowledge of this
                                               # is Services::API

    extend Core::Client::ModuleMethods         # per the pattern

    include Core::Client::InstanceMethods      # per the pattern

    event_class API::Event                     # necessary in 2 places b/c
                                               # of the two origins of events

  public

    def invoke normalized_action_name, params_h, events
      events[ self ]              # we have *got* to wire the api client to the
                                  # upstream for the infostream hack to
                                  # work (turning writes into infostream
                                  # events)
      result = nil
      begin
        k = API::Actions.const_fetch normalized_action_name,
          -> e do
            invalid "#{e.seen.last || 'actions'} has no \"#{ e.name }\" action"
          end,
          -> e do
            invalid "invalid action name: #{ e.invalid_name }"
          end
        k or break
        r = k.call self, params_h, events
        result = r
        if API.debug
          API.debug.puts "OK API GOT: #{ r.class }"
        end
      end while nil
      result
    end

    attr_writer :pen               # don't overwrite the reader you get
                                   # from sub-client
    def pen
      @pen or super                # simple submodule doesn't cover this
    end

  protected

    # a quick and dirty (and fun!) proof of concept to show that we can buffer
    # and then emit events in the API that originated as data from controllers
    # that was written directly to streams.
    # (simpler than H_L::IO::Interceptors::Filter, but that exists too)
    # note that this only emits on 'puts', hence you may lose trailing data
    #
    io_interceptor = -> emit do
      buffer = ::StringIO.new
      o = { }
      o[:write] = -> str do
        buffer.write str
        str.to_s.length
      end
      o[:puts] = -> str do
        buffer.puts str
        payload = buffer.string.dup # ! you've goota dup it
        buffer.truncate 0
        emit[ payload ]
        nil
      end
      x = MetaHell::Plastic::Instance[ o ] # a quick mock
      x
    end

    define_method :infostream do  # what's going on here is that because we
      @infostream ||= begin       # as the api only emit events, we try
        f = -> str do             # (for fun!?) to translate informational
                                  # stream writes into events..
          if event_listeners.empty?
            fail 'sanity - no listeners of api client on stream write!'
          end
          emit :info, str
          nil
        end
        io_interceptor[ f ]
      end
    end

    def invalid msg
      error "api runtime error : #{ msg }"
      false
    end
  end
end
