require_relative '../test-support'

module Skylab::Bnf2Treetop::API::Parameters end

module Skylab::Bnf2Treetop::API::Parameters::TestSupport
  def self.extended mod
    mod.module_eval do
      include InstanceMethods
    end
  end
  module InstanceMethods
    include ::Skylab::Bnf2Treetop::API::TestSupport::InstanceMethods
  end
end
