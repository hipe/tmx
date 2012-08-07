require_relative '../../core'

module Skylab::Headless
  module Parameter::TestSupport
    def self.extended obj
      obj.extend Parameter::TestSupport::ModuleMethods
      obj.send(:include, Parameter::TestSupport::InstanceMethods)
    end
  end
  module Parameter::TestSupport::ModuleMethods
    def defn &b
      @klass = ::Class.new.class_exec do
        def self.parameter_definition_class ; Parameter::Definition_ end
        extend Parameter::Definer::ModuleMethods
        include Parameter::Definer::InstanceMethods
        class_exec(&b)
        self
      end
    end
    def frame &b
      klass = @klass
      let(:object) { klass.new }
      instance_exec(&b)
    end
  end
  module Parameter::TestSupport::InstanceMethods
  end
end
