module Skylab::TanMan

  class Services::Config

  public

    names = [:local, :global].freeze

    define_method( :all_resource_names ) { names.dup }

    def clear_config_service
      global.clear_config_resource
      local.clear_config_resource
      nil
    end

    attr_reader :global

    attr_accessor :local

    private :'local='

                       # (The below used to be a more sophisticated and hard-
                       # to understand event graph but we have flattened it
                       # down (and wound it up) to the level of granularity
                       # we actually use above to provide some crucial clairty.)

    ready_struct = ::Struct.new(

      :escape_path,    # custom 'pen style' for modality-specific rendering

      :global_invalid, # when the global config file is found to be invalid

      :local_invalid,  # idem local

      :not_ready,      # in the local ready? graph, more general

      :no_config_dir   # in the local ready? graph, more specific

    )


    # @todo waiting for permute [#056]
    define_method :ready? do |&events|
      s = ready_struct.new                     # build this simple struct
      events[ s ]                              # and get the hooks here
      a = [ready_global?(s), ready_local?(s)]  # run both always
      r = ! a.index { |x| ! x }                # if one is not ok we are not ok
      r
    end

    def ready_global? ev
      res = nil
      if global.exist?
        if global.modified?
          res = global.read do |_ev|
            _ev.escape_path = ev.escape_path   # kind of yuck sorry
            _ev.invalid = ev.global_invalid or fail('sanity')
          end
        else
          res = global.valid?
        end
      else                                     # just because there is no
        res = true                             # global conf file does not mean
      end                                      # that there could not be one
      res
    end

    ready_local_emitter = API::Emitter.new :all, # [#043]
      not_ready: :all,
        no_config_dir: :not_ready,
          not_a_dir: :no_config_dir

    define_method :ready_local? do |ev|
      em = ready_local_emitter.new
      if ev.not_ready             # hopefully mutex with below, this is the
        em.on_not_ready { |e| ev.not_ready[ e ] } # more general event
      end
      if ev.no_config_dir         # and this is the more specific event
        em.on_no_config_dir { |e| ev.no_config_dir[ e ] }
      end
      meta = nil
      if ! local.path
        meta = find_local_path em, ev
        local.path = meta.found if meta.found # might be false
      end
      res = nil
      if local.path # if found then assume exists per above
        if local.modified?
          res = local.read do |_ev|
            _ev.escape_path = ev
            _ev.invalid = ev.local_invalid or fail 'sanity'
          end
        else
          res = local.valid?
        end
      else
        em.emit :no_config_dir,
          from:    meta.orig,
          dirname: meta.local_conf_dirname,
          message: "local conf dir not found"
        res = false
      end
      res
    end

    def resources
      [local, (global if global.exist?)].compact
    end

    def resources_count
      resources.count # what's one more filesystem call? :P
    end

  private

    def initialize
      # at this stage it is not determined that these files exist
      # nor that they are without syntax errors
      @global = TanMan::Models::Config::Resource::Global.new(
        entity_noun_stem: "global config file",
        normalized_resource_name: :global,
        path:  API.global_conf_path.call
      )
      @local = TanMan::Models::Config::Resource::Local.new(
        entity_noun_stem: "local config file",
        normalized_resource_name: :local,
        path: nil
      )
    end

    find_meta = ::Struct.new :orig, :found, :local_conf_dirname

    define_method :find_local_path do |em, e|
      o = find_meta.new
      maxdepth = API.local_conf_maxdepth # nil ok, zero means noop
      currdepth = 0
      limit_reached = maxdepth ? -> { currdepth >= maxdepth } : -> { false }
      current = o.orig = API.local_conf_startpath.call
      o.local_conf_dirname = API.local_conf_dirname
      found = nil
      loop do
        break if limit_reached[ ]
        try = current.join o.local_conf_dirname
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
      if found
        if found.directory?
           o.found = found.join API.local_conf_config_name
        else
          em.emit :not_a_dir, dir: found,
            message:  "not a directory: #{ e.escape_path[ found ] }"
          o.found = false
        end
      end
      o
    end
  end
end
