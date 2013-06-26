module Skylab::TestSupport

  class This_File
    class << self
      alias_method :[], :new
    end

    def initialize path
      @path = path
      @content = ::File.read path
    end

    def contains str
      @content.include? str
    end
  end
end
