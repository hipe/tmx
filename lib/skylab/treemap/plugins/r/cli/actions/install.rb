module Skylab::Treemap
  class Plugins::R::CLI::Actions::Install < Plugins::R::CLI::Action

    desc "for installing R"

    option_syntax.help!

    url_base = 'http://cran.stat.ucla.edu/'

    define_method :execute do
      emit :payload, "To install R, please download the package #{
        }for your OS from #{ url_base }"
    end
  end
end
