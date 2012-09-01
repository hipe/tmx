require_relative '../test-support'

module Skylab::Bnf2Treetop::API::Features end

module Skylab::Bnf2Treetop::API::Features::TestSupport
  def self.extended mod
    mod.module_eval do
      include InstanceMethods
    end
  end
  module InstanceMethods
    include ::Skylab::Bnf2Treetop::API::TestSupport::InstanceMethods
  end
end
