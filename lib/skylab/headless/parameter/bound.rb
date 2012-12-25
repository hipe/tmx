# encoding: UTF-8

module Skylab::Headless

  class Parameter::Bound < Struct.new(:parameter, :read_f, :write_f, :label_f)
    def name ; parameter.name end
    def label ; label_f.call(parameter) end
    def value ; read_f.call end
    def value=(x) ; write_f.call(x) end
  end

  class Parameter::Bound::Enumerator < ::Enumerator
    extend Parameter::Definer
    def self.[](param) ; Parameter::Bound::Enumerator::Proxy.new(param) end
    def initialize host_instance
      super() { |y| init ; visit(y) }
      @mixed = host_instance
      block_given? and raise ArgumentError.new(
        "i'm not that kind of enumerator (╯°□°）╯︵ ┻━┻")
    end
    def at *parameter_names
      dupe(
        params_f: ->() do          # Override the default to be more map-like,
          ::Enumerator.new do |y|  # and use only the desired names.
            parameter_names.each do |parameter_name| # But still, we lazy eval
              y << set_f.call.fetch(parameter_name)  # and fail late (for now).
            end                    # Also override the default visit_f which
          end                      # flattens list-like parameters.  We do
        end,                       # not want to flatten it.
        visit_f: ->(y, param) { y << bound(param) } # Do not flatten it.
      )                            # Don't do that to anyone.
    end
    def fetch parameter_name
      init
      bound set_f.call.fetch(parameter_name)
    end
    def where props_h=nil, &select_f
      props_h and props_f = ->(prop) do
        ! props_h.detect do |k, v|
          ! prop.known?(k) || prop[k] != v
        end
      end
      _filter_f =
      case [(:props if props_f), (:select if select_f)].compact
      when [:props, :select] ; ->(p) { props_f.call(p) && select_f.call(p) }
      when [:props]          ; props_f
      when [:select]         ; select_f
      when []                ; ->(param) { true }
      end
      dupe(params_f: ->() do
        ::Enumerator.new do |y|
          params_f.call.each { |p| _filter_f.call(p) and y << p }
        end
      end)
    end
  protected
    meta_param :inherit, boolean: true, writer: true
    param :known_f, accessor: true, inherit: true
    param :label_f, accessor: true, inherit: true
    param :params_f, accessor: true, inherit: true
    param :read_f, accessor: true, inherit: true
    param :set_f, accessor: true, inherit: true
    param :upstream_f, accessor: true, inherit: true
    param :visit_f, writer: true, inherit: true
    param :write_f, accessor: true, inherit: true
    def init
      @mixed &&= begin
        if ::Hash === @mixed then @mixed.each { |k, v| send("#{k}=", v) }
        else process_host_instance(@mixed)
        end
        nil
      end
    end
    def bound parameter
      Parameter::Bound.new(parameter,
        ->{ read_f.call(parameter) if known_f.call(parameter) },
        ->(val) { write_f.call(parameter, val) }, label_f)
    end
    def dupe changes
      init # should be ok to call multiple times
      self.class.new(Hash[
        self.class.parameters.each.select(&:inherit?).map do |param|
          [param.name, send(param.name)]
        end].merge(changes) )
    end
    def process_host_instance host_instance
      f = {}
      host_instance.instance_exec do
        f[:set_f] = ->{ formal_parameters }
        f[:params_f] = -> { formal_parameters.each.to_a }
        f[:known_f] = ->(param) { known? param.name }

        f[:label_f] = -> param, i=nil do
          if request_client
            parameter_label param, i
          else
            "#{ param }#{ "[#{ i }]" if i }" # #todo
          end
        end

        f[:read_f] = ->(param) do
          m = method(param.name) # catch these errors here, they are sneaky
          m.arity <= 0 or fail("You do not have a reader for #{param.name}")
          m.call
        end
        f[:upstream_f] = ->(param, val, &valid_f) do
          param.apply_upstream_filter(self, val, &valid_f)
        end
        f[:write_f] = ->(param, val) do
          param.apply_upstream_filter(self, val) { |v| self[param.name] = v }
        end
      end
      f.each { |k, v| send("#{k}=", v) }
    end
    def visit y
      params_f.call.each { |p| visit_f.call(y, p) }
    end
    # The builtin implementation for visit_f flattens list-like parameters
    # into each their own bound parameter.
    def visit_f
      @visit_f ||= (->(y, param) do
        # Note that the below implementation for processing list-likes relies
        # on the lists being implemented as array-like.  Also note that
        # it might fail variously if there are not readers / writers in place.
        if param.list?
          a = read_f.call(param) and a.length.times do |i| # nil iff zero items
            y << Parameter::Bound.new(param,
              ->{ a[i] }, # ok iff there is no lazy evaluation
              ->(val) { upstream_f.call(param, val) { |_val| a[i] = _val } },
              ->(_) { label_f.call(param, i) })
          end
        else
          y << bound(param)
        end
      end)
    end
  end

  module Parameter::Bound::InstanceMethods
    def bound_parameters
      Parameter::Bound::Enumerator::Proxy.new self
    end
  end

  class Parameter::Bound::Enumerator::Proxy
    # This may be a design smell, but see the commit where this thing first
    # appeared.  it is kind of a deep problem, and after some thought this
    # was considered the optimal solution.  suggestions welcome.
    def initialize host_instance
      @bridge = Parameter::Bound::Enumerator.new(host_instance)
    end
    def [](k) ; @bridge.fetch(k) end # !
    def at *a, &b ; @bridge.at(*a, &b) end
    def each *a, &b ; @bridge.each(*a, &b) end
    def where *a, &b ; @bridge.where(*a, &b) end
  end
end
