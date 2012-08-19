module Skylab::TanMan
  class API::Actions::Tell < API::Achtung
    param :words, accessor: true, list: true, required: true
  protected
    def execute
      ready? or return
      info("OK, here are some words: #{words.inspect}")
    end
    # -- * --
    attr_reader :path
    def ready?
      config.ready? or return
      config.known?('file') or return error("use use")
      @path = ::Pathname.new(config['file'])
      path.exist? or return error("must exist: #{path}")
      true
    end
  end
end
