require_relative '../test-support'

module Skylab::TanMan::Models::TestSupport
  def self.extended mod
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end
  module ModuleMethods
    include ::Skylab::TanMan::TestSupport::ModuleMethods
  end
  module InstanceMethods
    include ::Skylab::TanMan::TestSupport::InstanceMethods
  end
end
