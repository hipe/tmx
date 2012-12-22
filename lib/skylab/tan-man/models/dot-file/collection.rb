module Skylab::TanMan
  class Models::DotFile::Collection < ::Struct.new :selected_pathname
    include Core::SubClient::InstanceMethods

    def ready?
      ready.call
    end

    def selected
      res = nil
      begin
        break( res = @selected ) if @selected # (there is danger here in the ..
        break if ! ready? # emits info        # distant future)
        if ! selected_pathname
          info "no selected_pathname!" # strange
          break
        end
        # (at the time of this writing the controllers.dot_file seems to
        # be a sort of singleton, which might be dodgy. we want a controller
        # object that exists sort of one-to-one with a pathname.)
        cnt = Models::DotFile::Controller.new request_client # (up not me)
        cnt.pathname = selected_pathname
        res = cnt
        @selected = res
      end while nil
      res
    end

  protected

    def initialize request_client
      _headless_sub_client_init! request_client
      @ready = -> do
        result = false
        rc = self.request_client
        begin
          if ! controllers.config.ready?
            break
          end
          if ! controllers.config.known? 'file'
            error 'no "file" in config(s) - please use use'
            break
          end
          s = controllers.config['file']
          self.selected_pathname = ::Pathname.new s
          if selected_pathname.exist?
            result = true
          else
            error "must exist: #{ selected_pathname }"
          end
        end while nil
        result
      end
      @selected = nil
    end

    attr_reader :ready

    def controllers
      request_client.send :controllers # experimental - do we want this in
    end                           # sub-client?
  end
end
