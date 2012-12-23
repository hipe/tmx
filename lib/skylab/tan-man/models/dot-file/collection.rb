module Skylab::TanMan
  class Models::DotFile::Collection < ::Struct.new :using_pathname
    include Core::SubClient::InstanceMethods

    CONFIG_PARAM = 'using_dotfile'

    def currently_using
      res = nil
      begin
        if @currently_using                    # there is danger here in ..
          break( res = @currently_using )      # the distant future
        end
        break if ! ready? # emits info
        if ! using_pathname
          info "no using_pathname!" # strange
          break
        end
        # (at the time of this writing the controllers.dot_file seems to
        # be a sort of singleton, which might be dodgy. we want a controller
        # object that exists sort of one-to-one with a pathname.)
        cnt = Models::DotFile::Controller.new request_client # (up not me)
        cnt.pathname = using_pathname
        res = @currently_using = cnt
      end while nil
      res
    end

    def ready?
      ready.call
    end

  protected

    def initialize request_client
      _headless_sub_client_init! request_client
      @ready = -> do
        res = false
        begin
          conf = controllers.config
          rc = self.request_client
          if ! conf.ready?
            break
          end
          if ! conf.known? CONFIG_PARAM
            error "no '#{ CONFIG_PARAM }' value is set in config(s)" # no inv.
            break
          end
          relpath = conf[ CONFIG_PARAM ] or fail 'sanity'
          pathname = services.config.local.derelativize_path relpath
          self.using_pathname = pathname
          if using_pathname.exist?
            res = true
          else
            error "dotfile must exist: #{ escape_path using_pathname }"
          end
        end while nil
        res
      end
      @currently_using = nil
    end

    attr_reader :ready

    def controllers
      request_client.send :controllers # experimental - do we want this in
    end                           # sub-client?
  end
end
