module Skylab::TanMan


  class API::Client                            # the only thing that should
                                               # have knowledge of this
                                               # is Services::API

    extend Core::Client::ModuleMethods         # per the pattern

    include Headless::API::Client::InstanceMethods  # now we need parameter_label

    include Core::Client::InstanceMethods      # per the pattern

    event_factory API::Event::Factory          # necessary in 2 places b/c
                                               # of the two origins of events

  public

    def invoke normalized_action_name, param_h, events
      events[ self ]              # we have *got* to wire the api client to the
                                  # upstream for the infostream hack to
                                  # work (turning writes into infostream
                                  # events)
      result = nil
      begin
        k = API::Actions.const_fetch normalized_action_name,
          -> ne do
            nf = Headless::Name::Function::From::Module_Anchored.new ne.module.name,  API::Actions.name
            name_error "#{ nf.length.zero? ? 'actions' : nf.anchored_normal.
              join(' ') } has no \"#{ ne.const }\" action"
          end
        k or break
        r = k.call self, param_h, events
        result = r
        if API.do_debug
          API.debug_stream.puts "OK API GOT: #{ r.class }"
        end
      end while nil
      result
    end

    attr_reader :pen              # overwrite `super` which is e.g. delegating
                                  # to io_adapter.  see our `initialize`

    def expression_agent
      @pen or never
    end

    def expression_agent_for_subclient
      expression_agent  # until etc
    end

  private

    pen = Headless::API::Pen::Minimal.new

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

    def pen.ick x                 # render an invalid value
      x.inspect
    end

    def pen.lbl str               # render a business label name
      "\"#{ str }\""
    end

    def pen.par sym               # render a parameter name
      lbl sym
    end

    def pen.val x                 # render a business value
      x.inspect
    end

    define_method :initialize do |modality_client=nil|
      if modality_client           # if we are running under some mysterious
        @pen = modality_client.pen # client for some other strange new
      else                         # modality .. note that we do *not* call super(mc) for now, to check how narrow we can make this coupling
        @pen = pen
      end
      _tan_man_sub_client_init nil # ***DO NOT KEEP*** the modality client here
    end

    # a quick and dirty (and fun!) proof of concept to show that we can buffer
    # and then emit events in the API that originated as data from controllers
    # that was written directly to streams.
    # (simpler than H_L::IO::Interceptors::Filter, but that exists too)
    # note that this only emits on 'puts', hence you may lose trailing data
    #
    io_interceptor = -> emit do
      buffer = TanMan::Services::StringIO.new
      MetaHell::Proxy::Ad_Hoc[
        write: -> str do
          buffer.write str
          str.to_s.length
        end,
        puts: -> str do
          buffer.puts str
          payload = buffer.string.dup # ! you've goota dup it
          buffer.truncate 0
          emit[ payload ]
          nil
        end
      ]
    end

    define_method :infostream do  # what's going on here is that because we
      @infostream ||= begin       # as the api only emit events, we try
        f = -> str do             # (for fun!?) to translate informational
                                  # stream writes into events..
          if event_listeners.length.zero?
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
