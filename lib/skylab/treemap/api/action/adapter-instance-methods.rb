module Skylab::Treemap

  module API::Action::AdapterInstanceMethods
    extend ::Skylab::MetaHell::DelegatesTo # #while [#003]

    FailureWiring = Skylab::PubSub::Emitter.new(:failure)

    def activate_adapter! name, &wire
      e = FailureWiring.new(wire)
      set_adapter_name(name) do |o|
        o.on_failure { |_e| e.emit( _e ) }
      end or return false
      adapter_instance
    end

    def adapter_class
      adapters.active_class
    end

    def adapter_instance
      @adapter_instance ||= begin
        adapter_class or return
        o = adapter_class.new
        o.load_attributes(self.singleton_class)
        o
      end
    end

    delegates_to :api_client, :adapters

    def adapter_name= name
      set_adapter_name(name) do |o|
        o.on_failure { |e| add_validation_error(:adapter_name, name, "failed to load {{value}}: adapter #{e}") }
      end
      name
    end

    def set_adapter_name name, &wire
      e = FailureWiring.new(wire)
      found, a = adapters.fuzzy_match_name name
      err = case found.length
      when 0 ; "not found. #{s a, :no}known adapter#{s a} #{s a, :is} #{self.and a.map{|x| pre x}}".strip
      when 1 ; adapters.active_adapter_name = found.first ; nil
      else   ; "is ambiguous -- did you mean #{self.or found.map{|x| pre x}}?"
      end
      err and return (e.emit(:failure, "adapter #{pre name} #{err}") and false)
      adapters.active_adapter_name
    end
  end
end

