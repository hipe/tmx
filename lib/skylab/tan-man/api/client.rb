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
            name_error "#{e.seen.last || 'actions'} has no \"#{e.name}\" action"
          end,
          -> e do
            name_error "invalid action name: #{ e.invalid_name }"
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

  protected

    pen = Headless::API::IO::Pen::Minimal.new

    pen.define_singleton_method :escape_path do |str|
      result = nil
      pathname = ::Pathname.new str.to_s
      if '.' == pathname.dirname.to_s # if the pathname looks like it might be
        result = str              # bare, result is exactly like you got it.
      else                        # otherwise we go with a safest possible
        result = pathname.basename.to_s  # route and knock the whole dirname out
      end                         # of it.
      result
    end


    define_method :initialize do |modality_client=nil|
      if modality_client           # if we are running under some mysterious
        @pen = modality_client.send :pen # client for some other strange new
      else                         # modality .. note that we do *not* call super(mc) for now, to check how narrow we can make this coupling
        @pen = pen
      end
    end

    attr_reader :pen               # overwrite `super` which is e.g. delegating
                                   # to io_adapter.  see our `initialize`

    # a quick and dirty (and fun!) proof of concept to show that we can buffer
    # and then emit events in the API that originated as data from controllers
    # that was written directly to streams.
    # (simpler than H_L::IO::Interceptors::Filter, but that exists too)
    # note that this only emits on 'puts', hence you may lose trailing data
    #
    io_interceptor = -> emit do
      buffer = TanMan::Services::StringIO.new
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

    def name_error msg            # (just used in this file)
      error "api name error : #{ msg }"
      false
    end
  end
end
