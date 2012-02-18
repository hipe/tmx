require 'skylab/code-molester/config/file'


module Skylab::Tmx
  module Model; end
  class Model::Config < ::Skylab::CodeMolester::Config::File
    PATH = '~/.tmx'
    emits :all,
          :error     => :all,
          :info      => :all,
          :info_head => :all,
          :info_tail => :all,
          :out       => :all
  end
  class << Model::Config
    def build &b
      path = Model::Config::PATH.sub(/^~/) { ENV["HOME"] }
      new(path, &b)
    end
  end
end

