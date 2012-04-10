module Skylab::TanMan
  class Models::Config::Singleton
    def clear
      global.clear
      local.clear
    end
    def find_local_path e # @api private
      maxdepth = Api.local_conf_maxdepth # nil ok, zero means noop
      currdepth = 0
      limit_reached = maxdepth ? ->(){ currdepth >= maxdepth } : ->() { false }
      current = @_orig = Api.local_conf_startpath.call
      local_conf_dirname = @_local_conf_dirname = Api.local_conf_dirname
      found = nil
      loop do
        break if limit_reached.call
        break if (found = current.join(local_conf_dirname)).exist?
        found = nil
        (parent = current.parent) == current and break
        currdepth += 1
        current = parent
      end
      if found
        if found.directory?
          found.join(Api.local_conf_config_name)
        else
          e.emit(:not_a_dir, message: "not a directory: #{found.pretty}", dir: found)
          false
        end
      end
    end
    attr_reader :global
    def initialize
      # at this stage it is not determined that these files exist
      # nor that they are without syntax errors
      @global = Models::Config::Resource.new(
        label: "global config file",
        path:  Api.global_conf_path.call
      )
      @local = Models::Config::Local.new(
        label: "local config file",
        path: nil
      )
    end
    attr_accessor :local
    protected :'local='
    class OnReady < Api::Emitter.new(:all,
      not_ready: :all, no_config_dir: :not_ready, not_a_dir: :no_config_dir
      )
      attr_accessor :on_read_global
      attr_accessor :on_read_local
    end
    # @todo waiting for permute [#056]
    def ready? &b
      e = OnReady.new(b)
      ! [ready_local?(e), ready_global?(e)].index { |x| ! x }
    end
    def ready_global? e
      if global.exist?
        if global.modified?
          global.read(& e.on_read_global)
        else
          global.valid?
        end
      else
        true
      end
    end
    def ready_local? e
      if ! local.path
        local.path = find_local_path(e)
      end
      if local.path # if found then assume exists per above
        if local.modified?
          local.read(& e.on_read_local)
        else
          local.valid?
        end
      else
        e.emit(:no_config_dir,
          from:    @_orig,
          dirname: @_local_conf_dirname,
          message: "local conf dir not found"
        )
        false
      end
    end
    def resources
      [local, (global if global.exist?)].compact
    end
    def resources_count
      resources.count # what's one more filesystem call? :P
    end
  end
end

