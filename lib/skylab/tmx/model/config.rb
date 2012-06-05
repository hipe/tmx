require 'skylab/code-molester/config/file'


module Skylab::Tmx
  module Model
  end
  class Model::Config < ::Skylab::CodeMolester::Config::File
    PATH = '~/.tmxconfig'
  end
  class << Model::Config
    def build
      new( Model::Config::PATH.sub(/^~/) { ENV["HOME"] } )
    end
  end
end

