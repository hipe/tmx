module Skylab::GitViz

  module API  # b.c stowed away here :/
    extend MetaHell::MAARS
  end

  class API::Client < ::Struct.new :runtime

    include Core::Client_IM_

    def emit(*a)
      runtime.emit(*a)
    end

    # would-be services:
    attr_reader :y

    def initialize runtime
      super(runtime)
      @y = runtime.y  # svc now
      @vcs_name = :git
    end
    alias_method :svcs, :runtime  # idgaf blood
    def invoke req
      i = svcs.last_hot_local_normal
      k = API::Actions.const_get camelize( i ), false
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
  end
  module API
    @instance = Hash.new do |h, k|
      if h.key? k.object_id
        h[k.object_id]
      else
        h[ k.object_id ] = API::Client.new k
      end
    end
    class << self
      attr_reader :instance
    end
  end
end
