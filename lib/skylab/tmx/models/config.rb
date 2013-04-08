require 'skylab/code-molester/core'

module Skylab

  class TMX::Models::Config < CodeMolester::Config::File

    PATH = '~/.tmxconfig'

    def self.build
      p = Headless::CLI::PathTools::FUN.expand_tilde[ self::PATH ]
      new path: p
    end
  end
end
