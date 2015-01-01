require_relative '../test-support'

Skylab::Bnf2Treetop::API::Parameters = ::Module.new

module Skylab::Bnf2Treetop::API::Parameters::TestSupport

  def self.extended mod
    mod.module_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods

    include ::Skylab::Bnf2Treetop::API::TestSupport::InstanceMethods

    def normal_of str
      str.gsub( %r([[:space:]]+), ' ').strip
    end
  end
end
