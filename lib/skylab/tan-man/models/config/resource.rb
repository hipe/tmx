module Skylab::TanMan

  class Models::Config::Resource < CodeMolester::Config::File

    # @smell, experimental

    def clear
      @content = @mtime = nil
      @state = :initial
    end

    attr_accessor :label

    def remotes
      @remotes ||= begin
        TanMan::Models::Remote::Collection.new self
      end
    end

  protected

    def initialize *a
      @remotes = nil
      super
    end
  end


  class Models::Config::Local < Models::Config::Resource
    def clear
      super
      @pathname = nil
    end
  end
end
