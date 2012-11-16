require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/core' # just MUSTACHE_RX

module Skylab::Porcelain::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    Autoloader = ::Skylab::Autoloader
    Bleeding = ::Skylab::Porcelain::Bleeding
    EmitSpy = ::Skylab::TestSupport::EmitSpy
    Headless = ::Skylab::Headless
    MetaHell = ::Skylab::MetaHell
    Porcelain = ::Skylab::Porcelain
  end

  module ModuleMethods
    include CONSTANTS
    include Autoloader::Inflection::Methods # constantize
    include MetaHell::Klass::Creator::ModuleMethods # klass etc

    def incrementing_anchor_module!
      _head = constantize description
      _head =~ /\A[A-Z][_a-zA-Z0-9]*\z/ or fail "oops: #{_head.inspect}"
      _last = 0
      let :meta_hell_anchor_module do
        m = ::Module.new
        _const = "#{_head}#{_last += 1}"
        Bleeding.const_set _const, m
        m
      end
    end
  end

  module InstanceMethods
   include CONSTANTS
   include Autoloader::Inflection::Methods # constantize
   include MetaHell::Klass::Creator::InstanceMethods # klass!

  end
end
