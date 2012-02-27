# (requires happen at the bottom!)

module Skylab::GitViz
  class Api < Struct.new(:runtime)
    ROOT = Pathname.new('..').expand_path(__FILE__)
    def emit(*a)
      runtime.emit(*a)
    end
    def initialize runtime
      super(runtime)
    end
    def invoke req
      meth = runtime.stack.top.action.name.to_s
      require ROOT.join("api/#{meth}").to_s
      k = self.class.const_get(meth.gsub(/(?:^|-)([a-z])/) { $1.upcase })
      k.new(self, req).invoke
    end
    @instance = Hash.new do |h, k|
      if h.key? k.object_id
        h[k.object_id]
      else
        h[k.object_id] = new(k)
      end
    end
  end
  class << Api
    attr_reader :instance
  end
end

require File.expand_path('../api/action', __FILE__)

