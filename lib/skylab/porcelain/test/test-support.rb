require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Porcelain::TestSupport

  ::Skylab::TestSupport::Regret[ Porcelain_TestSupport = self ]

  module CONSTANTS
    Autoloader = ::Skylab::Autoloader
    Bleeding = ::Skylab::Porcelain::Bleeding
    Headless = ::Skylab::Headless
    MetaHell = ::Skylab::MetaHell
    Porcelain = ::Skylab::Porcelain
    PubSub = ::Skylab::PubSub
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods
    include CONSTANTS
    include MetaHell::Class::Creator::ModuleMethods # klass etc

    define_method :constantize, & Autoloader::FUN::Constantize

    def incrementing_anchor_module!  # so ridiculous
      head = Autoloader::FUN::Constantize[ description ]
      if /\A[A-Z][_a-zA-Z0-9]*\z/ !~ head
        fail "oops - #{ head }"
      else
        last_id = 0
        let :meta_hell_anchor_module do
          mod = Porcelain_TestSupport.const_set "#{ head }#{ last_id += 1 }",
            ::Module.new
          mod
        end
      end
    end
  end

  module InstanceMethods
   include CONSTANTS
   include MetaHell::Class::Creator::InstanceMethods # klass!

   define_method :style_free, & Headless::CLI::Pen::FUN.unstyle

   define_method :unstyle_styled,
     & Headless::CLI::Pen::FUN.unstyle_styled

   define_method :constantize, & Autoloader::FUN::Constantize

   attr_accessor :do_debug

   def debug!
     @do_debug = true
   end

   infostream = ::STDERR

   define_method :infostream do infostream end
  end
end
