require 'skylab/porcelain/bleeding'

module Skylab::Treemap
  extend Skylab::Autoloader

  class Action
    extend Skylab::Porcelain::Bleeding::Action
    def error s
      emit :error, s
      false
    end
    def info s
      emit :info, s
      true
    end
    def r
      Skylab::Treemap::R
      @r ||= Skylab::Treemap::R::Bridge.new
    end
  end
  module Actions
  end
  class Actions::Install < Action
    desc "for installing R"

    URL_BASE = 'http://cran.stat.ucla.edu/'
    def execute
      emit :payload, "To install R, please download the package for your OS from #{URL_BASE}"
    end
  end
  class Actions::Whatever < Action
    def execute
      require_relative 'actions/whatever'
      execute
    end
  end
end

