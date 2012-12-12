module Skylab::TanMan
  class Models::DotFile::Collection < ::Struct.new :selected_pathname
    include Core::SubClient::InstanceMethods

    def ready?
      ready.call
    end

  protected

    def initialize request_client
      _sub_client_init! request_client
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
    end

    attr_reader :ready

    def controllers
      request_client.send :controllers # experimental - do we want this in
    end                           # sub-client?
  end
end
