module Skylab::Cull

  class CLI::Actions::DataSource < CLI::Namespace

    option_parser do |o|
      # (ick for now this is necessary to get `aliases` working)
    end

    aliases :ls

    def list
      api
    end

    option_parser do |o|
      dry_run_option o
      verbose_option o

      @param_h[ :tag_a ] = false
      o.on '-t', '--tag <name>' do |v|
        ( @param_h[ :tag_a ] ||= [ ] ) << v
      end
    end

    def add name, url
      api name, url
    end
  end
end
