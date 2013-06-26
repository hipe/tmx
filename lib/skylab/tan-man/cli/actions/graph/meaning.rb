module Skylab::TanMan

  module CLI::Actions::Graph::Meaning::Actions

    MetaHell::Boxxy[ self ]

  end

  class CLI::Actions::Graph::Meaning::Actions::Add < CLI::Action

    desc "create new meaning"

    inflection.inflect.noun :singular

    option_parser do |o|
      dry_run_option o
      help_option o
      verbose_option o
    end

    def process name, value
      api_invoke [:graph, :meaning, :learn],
        { create: true, dry_run: false, name: name,
          value: value, verbose: false }.merge( param_h )
    end
  end

  class CLI::Actions::Graph::Meaning::Actions::Change < CLI::Action

    desc "alter existing meaning"

    inflection.inflect.noun :singular

    option_parser do |o|
      dry_run_option o
      help_option o
      verbose_option o
    end

    def process name, value
      api_invoke [:graph, :meaning, :learn],
        { create: false, dry_run: false, name: name,
          value: value, verbose: false }.merge( param_h )
    end
  end

  class CLI::Actions::Graph::Meaning::Actions::Forget < CLI::Action

    desc "delete the meaning entry from the dotfile"

    inflection.inflect.noun :singular


    option_parser do |o|
      dry_run_option o

      o.on '-f', '--force', "sometimes necessary." do param_h[:force] = true end

      help_option o
      verbose_option o
    end

    def process name
      api_invoke [:graph, :meaning, :forget],
        { dry_run: false, force: false, name: name, verbose: false }.
          merge( param_h )
    end
  end

  class CLI::Actions::Graph::Meaning::Actions::List < CLI::Action

    desc "list all known meanings"

    inflection.inflect.noun :plural

    option_parser do |o|
      help_option o
      verbose_option o
    end

    def process
      api_invoke [:graph, :meaning, :list], { verbose: false }.merge( param_h )
    end
  end
end
