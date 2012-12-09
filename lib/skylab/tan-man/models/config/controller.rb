module Skylab::TanMan

  class Models::Config::Controller
    include Core::SubClient::InstanceMethods # yay

    def [] k # is ready? and k is string and local is the thing
      fail 'make this first found' # #TODO
      services.config.local[k]
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

    def known? name, resource_name           # is ready? and name is string
      result = nil
      if :all == resource_name
        result = services.config.all_resource_names.detect do |n|
          resources[ n ].key? name
        end
      else
        result = resources[ resource_name ].key? name
      end
      result
    end

    def load_default_content resource
      x = resource.sexp
      o = -> s { x.prepend_comment s }
      o[ '' ] # in reverse
      o[ "parts of this file may have been generated and may be overwritten" ]
      o[ "created #{ Time.now.localtime } by tanman" ]
      nil
    end

    def ready?
      services.config.ready? do |o|            # compare to actions/status.rb

        o.escape_path = ->( p ) { escape_path p } # per modality!

        o.no_config_dir = -> e do
          emit :no_config_dir, e               # same payload, different graph!
        end

        o.global_invalid = -> e do
          error e
        end

        o.local_invalid = o.global_invalid
      end
    end

    def remotes
      @remotes ||= Models::Config::Remotes.new request_client
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

    def write_resource resource
      result = nil
      begin
        if resource.exist? && resource.pathname.read == resource.string
          emit :info, "(config file didn't change.)"
          result = true
          break
        end
        if ! resource.exist?
          load_default_content resource
        end
        is = infostream # a special case
        result = resource.write do |o|
          o.on_error { |e| error e.message } # we *must* convert from plain to
          o.on_before_edit { |e| is.write e.touch!.message } # custom event
          o.on_before_create { |e| is.write e.touch!.message }
          b = -> e { is.puts " .. done (#{ e.touch!.bytes } bytes.)" }
          o.on_after_edit(& b)
          o.on_after_create(& b)
          o.on_all { |e| info e.message unless e.touched? }
        end
      end while nil
      result
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

  protected

    def initialize request_client
      @remotes = nil
      _sub_client_init! request_client
    end


    def resources
      resources = -> name do                   # memoize a lamba that from
        r = services.config.send name          # the outside might look like
        r                                      # a hash
      end
      define_singleton_method( :resources ) { resources }
      send :resources # HAHAHAH
    end
  end
end
