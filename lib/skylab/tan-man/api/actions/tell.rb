module Skylab::TanMan
  class API::Actions::Tell < API::Achtung
    param :words, accessor: true, list: true, required: true

    include TanMan::Statement::Parser::InstanceMethods
  protected
    def execute
      ready? or return
      stmnt = parse_words(words) or return
      Models::DotFile::Controller.new(request_runtime).invoke(
                                                   statement: stmnt, path: path)
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
