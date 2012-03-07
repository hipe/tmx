# (requires happen at the bottom!)

module Skylab::GitViz
  class Api < Struct.new(:runtime)
    ROOT = Pathname.new('..').expand_path(__FILE__)
    def emit(*a)
      runtime.emit(*a)
    end
    def initialize runtime
      super(runtime)
      @vcs_name = :git
    end
    def invoke req
      meth = runtime.stack.top.action.name.to_s
      require ROOT.join("api/#{meth}").to_s
      k = self.class.const_get(camelize meth)
      k.new(self, req).invoke
    end
    define_method(:root) { ROOT }
    def vcs
      @vcs ||= begin
        require ROOT.join("api/vcs-adapter/#{vcs_name}")
        self.class::VcsAdapter.const_get(camelize vcs_name).new(self)
      end
    end
    attr_reader :vcs_name
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
  module Api::Actions
  end
  module Api::Model
  end
  module Api::InstanceMethods
    def camelize s
      s.to_s.gsub(/(?:^|-)([a-z])/) { $1.upcase }
    end
  end
  Api.send(:include, Api::InstanceMethods)
end

require File.expand_path('../api/action', __FILE__)

