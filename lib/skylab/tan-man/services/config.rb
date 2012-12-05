module Skylab::TanMan

  class Services::Config

  public

    names = [:local, :global].freeze

    define_method( :all_resource_names ) { names.dup }

    def clear
      global.clear
      local.clear
    end

    attr_reader :global

    attr_accessor :local

    protected :'local='

    class OnReady < API::Emitter.new(:all, # [#043]
      not_ready: :all, no_config_dir: :not_ready, not_a_dir: :no_config_dir
      )
      attr_accessor :on_read_global
      attr_accessor :on_read_local
    end

    # @todo waiting for permute [#056]
    def ready? &b
      e = OnReady.new b
      a = [ready_local?(e), ready_global?(e)]
      r = ! a.index { |x| ! x }
      r
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
        local.path = find_local_path e
      end
      r = nil
      if local.path # if found then assume exists per above
        if local.modified?
          r = local.read(& e.on_read_local)
        else
          r = local.valid?
        end
      else
        e.emit :no_config_dir,
          from:    @_orig,
          dirname: @_local_conf_dirname,
          message: "local conf dir not found"
        r = false
      end
      r
    end

    def resources
      [local, (global if global.exist?)].compact
    end

    def resources_count
      resources.count # what's one more filesystem call? :P
    end

  protected

    def initialize
      # at this stage it is not determined that these files exist
      # nor that they are without syntax errors
      @global = TanMan::Models::Config::Resource.new(
        label: "global config file",
        path:  API.global_conf_path.call
      )
      @local = TanMan::Models::Config::Local.new(
        label: "local config file",
        path: nil
      )
    end

    def find_local_path e
      maxdepth = API.local_conf_maxdepth # nil ok, zero means noop
      currdepth = 0
      limit_reached = maxdepth ? -> { currdepth >= maxdepth } : -> { false }
      current = @_orig = API.local_conf_startpath.call
      local_conf_dirname = @_local_conf_dirname = API.local_conf_dirname
      found = nil
      loop do
        break if limit_reached.call
        try = current.join local_conf_dirname
        if try.exist?
          found = try
          break
        end
        parent = current.parent
        if parent == current
          break
        end
        currdepth += 1
        current = parent
      end
      result = nil
      if found
        if found.directory?
          result = found.join API.local_conf_config_name
        else
          e.emit :not_a_dir, dir: found,
            message:  "not a directory: #{ found.pretty }"
          result = false
        end
      end
      result
    end
  end
end
