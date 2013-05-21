module Skylab::TestSupport::Regret::CLI

  CLI = self
  TestSupport = ::Skylab::TestSupport
  Face = TestSupport::Services::Face
  Regret = TestSupport::Regret

  class Regret::CLI::Client < Face::CLI

    Regret::API::Conf::Verbosity[ self ]

    Face::Services::Headless::Plugin::Host.enhance self do
      service_names %i| out err pth invitation |
    end

    def initialize( * )
      super
      @param_h = { }
      @pth = Face::Services::Headless::CLI::PathTools::FUN.pretty_path
      nil
    end

    option_parser do |o|
      o.separator "#{ hi 'description:' } try it on a file"
      o.on '-v', '--verbose', 'verbose. (try mutliple.)', & verbosity_opt_func
      o.on '-V', '--less-verbose', 'reduce verbosity.', &
       deincrement_verbosity_opt_func
      o.banner = @command.usage_line
    end

    def doc_test path
      api path
    end

    option_parser do |o|
      o.separator "\n#{ hi 'description:' } make intermediate test files."
      o.separator "always safe to run - never clobbers.\n\n"
      o.separator "#{ hi 'options:' }"

      @param_h[:do_preview] = nil
      o.on '-p', '--preview', 'writes file output to stderr' do
        @param_h[:do_preview] = true
      end

      o.on '-v', '--verbose', 'verbose (try multiple.)', & verbosity_opt_func
      o.on '-V', '--less-verbose', 'reduce verbosity.', &
        deincrement_verbosity_opt_func

      o.on '-n', '--dry-run', 'dry-run.' do
        @param_h[:is_dry_run] =true
      end
      o.banner = @command.usage_line
    end

    def intermediates path
      api path
    end

  private
  dsl_off

    # implement services:

    def pth ; @pth end  # avoid `private attribute?` warning

    def invitation
      invite_for @y, @last_normalized_child_slug
      nil
    end
  end
end
