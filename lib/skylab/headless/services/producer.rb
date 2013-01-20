module Skylab::Headless
  class Services::Producer

    def gets
      @enum.next if @live
    rescue ::StopIteration
      @live = nil
    end

  protected

    def initialize enum
      @live = true
      @enum = enum
    end
  end
end
