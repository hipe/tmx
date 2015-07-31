# encoding: UTF-8

module Skylab::Headless

  class Parameter::Bound < Struct.new(:parameter, :read_p, :write_p, :label_p)
    def normalized_parameter_name ; parameter.normalized_parameter_name end
    def label ; label_p.call(parameter) end
    def value ; read_p.call end
    def value=(x) ; write_p.call(x) end
  end

  class Parameter::Bound::Enumerator < ::Enumerator
    Parameter::Definer[ self ]
    def self.[](param) ; Parameter::Bound::Enumerator::Proxy.new(param) end
    def initialize host_instance
      super() { |y| init ; visit(y) }
      @mixed = host_instance
      block_given? and raise ArgumentError.new(
        "i'm not that kind of enumerator (╯°□°）╯︵ ┻━┻")
    end
    def at *parameter_names
      reduce_with_changes(
        params_p: ->() do          # Override the default to be more map-like,
          ::Enumerator.new do |y|  # and use only the desired names.
            parameter_names.each do |parameter_name| # But still, we lazy eval
              y << set_p.call.fetch(parameter_name)  # and fail late (for now).
            end                    # Also override the default visit_p which
          end                      # flattens list-like parameters.  We do
        end,                       # not want to flatten it.
        visit_p: ->(y, param) { y << bound(param) } # Do not flatten it.
      )                            # Don't do that to anyone.
    end
    def fetch parameter_name
      init
      bound set_p.call.fetch(parameter_name)
    end

    def reduce_by_ props_h=nil, & select_p

      if props_h
        props_p = -> prop do
          ! props_h.detect do |k, v|
            ! prop.known?(k) || prop[k] != v
          end
        end
      end

      _filter_p =
      case [(:props if props_p), (:select if select_p)].compact
      when [:props, :select] ; ->(p) { props_p.call(p) && select_p.call(p) }
      when [:props]          ; props_p
      when [:select]         ; select_p
      when []                ; MONADIC_TRUTH_
      end

      reduce_with_changes( params_p: -> do
        ::Enumerator.new do |y|
          params_p.call.each { |p| _filter_p.call(p) and y << p }
        end
      end )
    end

  private

    meta_param :inherit, boolean: true, writer: true
    param :known_p, accessor: true, inherit: true
    param :label_p, accessor: true, inherit: true
    param :params_p, accessor: true, inherit: true
    param :read_p, accessor: true, inherit: true
    param :set_p, accessor: true, inherit: true
    param :upstream_p, accessor: true, inherit: true
    param :visit_p, writer: true, inherit: true
    param :write_p, accessor: true, inherit: true
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
        ->{ read_p.call(parameter) if known_p.call(parameter) },
        ->(val) { write_p.call(parameter, val) }, label_p)
    end
    def reduce_with_changes changes
      init # should be ok to call multiple times
      self.class.new(Hash[
        self.class.parameters.each_value.select(&:inherit?).map do |param|
          [param.normalized_parameter_name, send(param.normalized_parameter_name)]
        end].merge(changes) )
    end
    def process_host_instance host_instance
      f = {}
      host_instance.instance_exec do
        f[:set_p] = ->{ formal_parameters }
        f[:params_p] = -> { formal_parameters.to_a }
        f[:known_p] = ->(param) { known? param.normalized_parameter_name }

        f[:label_p] = -> param, i=nil do
          if request_client
            parameter_label param, i
          else
            "#{ param }#{ "[#{ i }]" if i }" # #todo
          end
        end

        f[:read_p] = ->(param) do
          m = method(param.normalized_parameter_name) # catch these errors here, they are sneaky
          m.arity <= 0 or fail("You do not have a reader for #{param.normalized_parameter_name}")
          m.call
        end
        f[:upstream_p] = ->(param, val, &valid_p) do
          param.apply_upstream_filter(self, val, &valid_p)
        end
        f[:write_p] = ->(param, val) do
          param.apply_upstream_filter(self, val) { |v| self[param.normalized_parameter_name] = v }
        end
      end
      f.each { |k, v| send("#{k}=", v) }
    end
    def visit y
      params_p.call.each { |p| visit_p.call(y, p) }
    end
    # The builtin implementation for visit_p flattens list-like parameters
    # into each their own bound parameter.
    def visit_p
      @visit_p ||= (->(y, param) do
        # Note that the below implementation for processing list-likes relies
        # on the lists being implemented as array-like.  Also note that
        # it might fail variously if there are not readers / writers in place.
        if param.list?
          a = read_p.call(param) and a.length.times do |i| # nil iff zero items
            y << Parameter::Bound.new(param,
              ->{ a[i] }, # ok iff there is no lazy evaluation
              ->(val) { upstream_p.call(param, val) { |_val| a[i] = _val } },
              ->(_) { label_p.call(param, i) })
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

    def reduce_by * a, & p
      @bridge.reduce_by_( * a, & p )
    end
  end
end
