require 'skylab/code-molester/core'

module Skylab

  class TMX::Models::Config < CodeMolester::Config::File

    PATH = '~/.tmxconfig'

    def self.build
      new path: Headless::CLI::PathTools::FUN.expand_tilde[ self::PATH ]
    end
  end
end
