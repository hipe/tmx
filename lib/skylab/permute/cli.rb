require File.expand_path('../api', __FILE__)
require 'skylab/porcelain/all'
require 'skylab/slake/muxer'

module Skylab::Permute
  module Cli
  end
  class << Cli
    def invoke argv, &b
      Invocation.new(&b).invoke(argv)
    end
  end
  class Invocation
    extend ::Skylab::Porcelain
    porcelain do
      emits :out
      default :foo
    end
    def foo
      puts 'RUNNING FOO'
    end
    def bar
      puts 'RUNNING BAR'
    end
  end
end

