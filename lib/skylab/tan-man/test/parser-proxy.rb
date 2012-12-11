module Skylab::TanMan::TestSupport
  class ParserProxy
    # the point of this (somewhat experimentally) is to see if we can have
    # a 'pure' parser thing that is divorced from our client controller
    # with a minimal amount of dedicated logic

    include TanMan::Models::DotFile::Parser::InstanceMethods

    attr_accessor :dir_path

    def dir_pathname
      @dir_pathname ||= (dir_path and ::Pathname.new(dir_path))
    end

    attr_accessor :profile

  protected

    def parser_result result
      res = super
      begin
        profile or break
        is =
          input_adapter.type.is? TreetopTools::Parser::InputAdapter::Types::FILE
        is or break
        ms = parse_time_elapsed_seconds * 1000
        path = input_adapter.pathname.basename.to_s
        info( '      (%2.1f ms to parse %s)' % [ms, path] )
      end while nil
      res
    end
  end
end
