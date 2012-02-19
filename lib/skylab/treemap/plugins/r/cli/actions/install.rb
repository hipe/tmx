module Skylab::Treemap::Plugins::R
  class CLI::Actions::Install < Skylab::Treemap::CLI::Action
    desc "for installing R"

    option_syntax.help_enabled = true

    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
end

