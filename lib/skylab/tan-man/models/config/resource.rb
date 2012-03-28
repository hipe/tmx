require 'skylab/code-molester/config/file'
Skylab::TanMan::CodeMolester = Skylab::CodeMolester # in only once place!

module Skylab::TanMan
  class Models::Config::Resource < CodeMolester::Config::File
    def initialize *a
      @remotes = nil
      super
    end
    attr_accessor :label
    def remotes
      @remotes ||= begin
        require_relative '../remote'
        Models::Remote::Collection.new(self)
      end
    end
  end
end

