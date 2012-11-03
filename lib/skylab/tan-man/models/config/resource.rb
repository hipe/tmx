require 'skylab/code-molester/config/file'
Skylab::TanMan::CodeMolester = Skylab::CodeMolester # in only once place!

module Skylab::TanMan
  class Models::Config::Resource < CodeMolester::Config::File
    # @smell, experimental
    def clear
      @content = @mtime = nil
      @state = :initial
    end
    def initialize *a
      @remotes = nil
      super
    end
    attr_accessor :label
    def remotes
      @remotes ||= begin
        TanMan::Models::Remote::Collection.new self
      end
    end
  end
  class Models::Config::Local < Models::Config::Resource
    def clear
      super
      @pathname = nil
    end
  end
end

