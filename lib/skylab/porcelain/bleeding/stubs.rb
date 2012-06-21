module Skylab::Porcelain::Bleeding
  module Stubs
    def self.extended mod
      mod.send :extend,  Stubs::ModuleMethods
      mod.send :include, Stubs::InstanceMethods
    end
  end
  module Stubs::InstanceMethods
    def find token
      action = super or return action
      if action.respond_to?(:stub?) && action.stub?
        action = self.action.real_actions_module.const_get(action.const)
      end
      action
    end
    def help_list
      if action.stubs == action.actions_module
        action.stubs.values.each { |s| action.real_actions_module.const_get(s.const) }
        action.actions_module = action.real_actions_module
      end
      super
    end
  end
  module Stubs::ModuleMethods
    def actions
      case (@stubs_state ||= :initial)
      when :initial ; @real_actions_module = actions_module
                      self.actions_module stubs
                      @stubs_state = :initialized
      end
      super
    end
    attr_reader :real_actions_module
    CONST = :ActionStubs
    def stubs
      @stubs ||= begin
        const_defined?(CONST) ? const_get(CONST) : begin
          const_set(CONST, Stubs::FakeModule.new(self))
        end
      end
    end
  end
  class Stub < Struct.new(:const)
    def name
      const.gsub(/(?:^|([a-z]))([A-Z])/) { "#{$1}#{'-' if $1}#{$2}" }.downcase
    end
    def names
      [name]
    end
    def visible?
      true
    end
    def stub?
      true
    end
    def summary
      fail("no")
    end
  end
  class Stubs::FakeModule < Hash
    alias_method :constants, :keys
    alias_method :const_get, :[]
    def initialize mod
      @mod = mod
    end
    def load_actions!
      (@loaded ||= nil) and return
      @mod.real_actions_module.dir.children.each do |child|
        const = child.basename.to_s.sub(/\.rb\z/,'').gsub(/(?:^|-)([a-z])/){ $1.upcase }
        self[const] = Stub.new(const)
      end
      @loaded = true
    end
  end
end


