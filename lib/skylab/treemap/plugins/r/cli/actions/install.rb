module Skylab::Treemap
  class CLI::Actions::Install < CLI::Action
    desc "for installing R"

    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
end

