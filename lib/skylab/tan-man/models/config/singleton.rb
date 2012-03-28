module Skylab::TanMan
  class Models::Config::Singleton
    def clear_cache!
      @global = @local = nil # @todo this is dodgy as fuck
    end
    def global
      @global and return @global
      @global = Models::Config::Resource.new(
        label: "global config file",
        path:  Api.global_conf_path.call
      ) # there is no guarantee that there isn't a sytax error!
    end
    def initialize
      @global = @local = nil
    end
    attr_accessor :local
    protected :'local='
    def ready? e
      local and return true
      maxdepth = Api.local_conf_maxdepth # nil ok, zero means noop
      currdepth = 0
      limit_reached = maxdepth ? ->(){ currdepth >= maxdepth } : ->() { false }
      orig = current = Api.local_conf_startpath.call
      local_conf_dirname = Api.local_conf_dirname
      not_found = ->() do
        e.emit(:no_config_dir) do
          { :from => orig, :dirname => local_conf_dirname, :message => "local conf dir not found" }
        end
        false
      end
      until limit_reached.call || (found = current.join(local_conf_dirname)).exist?
        (parent = current.parent) == current and return not_found.call
        currdepth += 1
        current = parent
      end
      limit_reached.call and return not_found.call
      self.local = Models::Config::Resource.new(
        label: "local config file",
        path: found.join(Api.local_conf_config_name)
      )
      local.exist?  and ! local.read(& e.on_read_local) and return false
      global.exist? and ! global.read(& e.on_read_global) and return false
      true
    end
    def resources
      [local, (global if global.exist?)].compact
    end
    def resources_count
      resources.count # what's one more filesystem call? :P
    end
  end
end

