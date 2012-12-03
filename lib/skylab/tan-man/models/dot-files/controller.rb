module Skylab::TanMan
  class Models::DotFiles::Controller < ::Struct.new :selected_pathname
    include Core::SubClient::InstanceMethods

    def ready?
      ready.call
    end

  protected

    def initialize request_client, config
      _sub_client_init! request_client
      @ready = -> do
        result = false
        begin
          if ! config.ready?
            break
          end
          if ! config.known? 'file', :all
            error 'use use'
            break
          end
          s = config['file']
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
  end
end
