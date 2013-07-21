module Skylab::TanMan

  Models::Config::Value_Metadata = ::Struct.new :name, :value, :value_was_set,
      :searched_resources, :found_resource_index

  class Models::Config::Controller

    include Core::SubClient::InstanceMethods # yay

    def [] k # is ready? and k is string - result is first found
      res = nil
      resources.each do |resrc| # order matters here, should be local -> global
        if resrc.key? k
          res = resrc[k]
          break
        end
      end
      res
    end

    def add_remote name, url, resource_name
      result = false
      begin
        ready? or break
        resource = resources[ resource_name ]
        remote = Models::Remote::Controller.new self # sub-client yay!
        ok = remote.edit name: name, url: url do |x|
          x.on_error { |e| emit e } # #experimental pattern
        end
        ok or break
        name = remote.name # normalization maybe
        collection = resource.remotes
        o = collection.detect { |r| name == r.name }
        if o
          emit :info, "remote #{ name.inspect } already exists."
          result = true
        else
          collection.push remote
          result = write_resource resource
        end
      end while nil
      result
    end

    def known? name, resource_name=:all        # is ready? and name is string
      result = nil
      if :all == resource_name
        result = resources.each.detect do |resource|
          resource.key? name
        end
        result = !! result # avoid temptation
      else
        result = resources[ resource_name ].key? name
      end
      result
    end

    def load_default_content resource
      x = resource.sexp
      o = -> s do
        x.prepend_comment s
      end
      o[ '' ] # in reverse
      o[ "parts of this file may have been generated and may be overwritten" ]
      o[ "created #{ Time.now.localtime } by tanman" ]
      nil
    end

    def ready? err=nil
      services.config.ready? do |o|            # compare to actions/status.rb

        o.escape_path = ->( p ) { escape_path p } # per modality!

        o.no_config_dir = -> e do
          if err then err[ e ] else
            emit :no_config_dir, e            #  same payload, different graph!
          end
        end

        o.global_invalid = -> e do
          if err then err[ e ] else error e end
        end

        o.local_invalid = o.global_invalid
      end
    end

    def remotes
      @remotes ||= Models::Config::Remote::Collection.new request_client
    end

    def remove_remote remote_name, resource_name
      remotes.remove remote_name, resource_name do |o|
        o.on_write = -> e { write_resource e.touch!.resource }
        o.on_all   = -> e { emit e unless e.touched? }
        o.on_remote_not_found do |e|
          error "couldn't find a remote named #{ e.remote_name.inspect }"
          a = remotes.map { |r| kbd r.name }
          rc = e.resources_count
          x = "#{ s a, :no }known remote#{s a} #{s a, :is} #{ and_ a }".strip
          x = "#{x} in #{ s rc, :this }#{" #{ rc }" unless 1==rc }#{
              } searched config resource#{ s rc }." # #linguitastic
          e.touch!
          info x
        end
      end
    end

    define_method :value_meta do |name, resource_name=:all|
      res = nil
      begin
        ready? or break
        meta = Models::Config::Value_Metadata.new nil, nil, nil, []
        name = name.to_s # convert symbols to strings or 'key?' fails!
        meta.name = name
        resource = nil
        if :all == resource_name
          resource, index = resources.each.with_index.detect do |resc,|
            meta.searched_resources.push resc
            resc.key? name
          end
          if resource
            meta[:found_resource_index] = index
            meta[:value_was_set] = true
          end
        else
          resource = resources[ resource_name ]
          meta.searched_resources.push resource
          if resource.key? name
            meta[:value_was_set] = true
            meta[:found_resource_index] = 0
          end
        end
        res = meta
        resource or break
        if meta[:value_was_set]
          meta[:value] = resource[ name ]
        end
      end while nil
      res
    end

    attr_accessor :verbose # compat

    def write_resource resource

      if ! resource.exist?
        load_default_content resource
      end

      serr = infostream # a special case

      resource.write do |w|

        w.on_error(& method( :error ) ) # propagate the text msg up

        w.on_before_create w.on_before_update -> o do  # first part of msg
          serr.write o.message_proc[]
        end

        w.on_after_create w.on_after_update -> o do  # last part
          serr.puts " .. done (#{ o.bytes } bytes.)"
        end

        w.on_no_change do |txt|
          info txt
        end

        w.if_unhandled_non_taxonomic_streams method( :raise )

        nil
      end
    end

    def set_value name, value, resource_name
      result = false
      begin
        ready? or break
        name = name.to_s # convert symbols to strings or 'key?' fails!
        resource = resources[ resource_name ]
        result =
        if resource.key? name
          before = resource[name]
          if value == before
            info "#{ name } already set to #{ before.inspect }"
            true
          else
            info "changing #{name} from #{ before.inspect } to #{value.inspect}"
            resource[name] = value
            write_resource resource
          end
        else
          info "creating #{ name } value: #{ value.inspect }"
          resource[name] = value
          write_resource resource
        end
      end while nil
      result
    end

  private

    def initialize request_client
      @remotes = nil
      init_headless_sub_client request_client
    end

    def resources
      resources = -> name do                   # memoize a lamba that from
        r = services.config.send name          # the outside might look like
        r                                      # a hash
      end

      enumerator = -> do
        ::Enumerator.new do |y|
          names = services.config.all_resource_names
          names.each do |name|
            resource = services.config.send name
            y << resource
          end
          nil
        end
      end

      resources.define_singleton_method :each do |&block|
        e = enumerator[ ]
        if block
          e.each { |x| block[ x ] }
        else
          e
        end
      end

      define_singleton_method( :resources ) { resources }

      resources
    end
  end
end
