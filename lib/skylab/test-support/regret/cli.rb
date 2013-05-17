module Skylab::TestSupport::Regret::CLI

  CLI = self
  TestSupport = ::Skylab::TestSupport
  Face = TestSupport::Services::Face
  Regret = TestSupport::Regret

  class Regret::CLI::Client < Face::CLI

    Face::Services::Headless::Plugin::Host.enhance self do
      service_names %i| out err pth |
    end

    def initialize( * )
      super
      @pth = Face::Services::Headless::CLI::PathTools::FUN.pretty_path
      nil
    end

    attr_reader :pth

    option_parser do |o|
      @param_h ||= { }
      o.separator "#{ hi 'description:' } try it on a file"
      o.banner = @command.usage_line
      o.on '-v', '--verbose', 'verbose.' do
        @param_h[:verbose_count] ||= 0
        @param_h[:verbose_count] += 1
      end
    end

    def doc_test path
      api path
    end
  end
end
