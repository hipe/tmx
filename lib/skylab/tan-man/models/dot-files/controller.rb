module Skylab::TanMan
  class Models::DotFiles::Controller < ::Struct.new :selected_pathname
    include ::Skylab::Headless::SubClient::InstanceMethods

    def ready?
      @ready_f.call
    end

  protected

    def initialize parent_client, config
      self.parent_client = parent_client
      @ready_f = -> do
        config.ready? or return
        config.known?('file') or return error("use use")
        self.selected_pathname = ::Pathname.new(config['file'])
        selected_pathname.exist? or
          return error("must exist: #{selected_pathname}")
        true
      end
    end
  end
end
