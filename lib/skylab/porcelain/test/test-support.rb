require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Porcelain::TestSupport

  ::Skylab::TestSupport::Regret[ Porcelain_TestSupport = self ]

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  TestLib_ = ::Module.new

  module CONSTANTS
    Bleeding = ::Skylab::Porcelain::Bleeding
    Callback_ = Callback_
    Porcelain = ::Skylab::Porcelain
    TestLib_ = TestLib_
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  extend TestSupport::Quickie

  module TestLib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Class_creator = -> do
      MetaHell__[]::Class::Creator
    end
    CLI = -> do
      Headless__[]::CLI
    end
    Constantize_proc = -> do
      Callback_::Name.lib.constantize
    end
    Headless__ = sidesys[ :Headless ]
    Let = -> mod do
      mod.extend MetaHell__[]::Let
    end
    Memoize = -> p do
      MetaHell__[]::FUN.memoize[ p ]
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Method_is_defined_by_module = -> i, mod do
      MetaHell__[]::FUN.module_defines_method_in_some_manner[ mod, i ]
    end
    Module_creator = -> do
      MetaHell__[]::Module::Creator
    end
  end

  module ModuleMethods
    include CONSTANTS
    include TestLib_::Class_creator[]::ModuleMethods  # klass etc

    define_method :constantize, & TestLib_::Constantize_proc[]

    def incrementing_anchor_module!  # so ridiculous
      head = TestLib_::Constantize_proc[][ description ]
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
   include TestLib_::Class_creator[]::InstanceMethods  # klass!

   define_method :style_free, & TestLib_::CLI[]::Pen::FUN.unstyle

   define_method :unstyle_styled,
     & TestLib_::CLI[]::Pen::FUN.unstyle_styled

   define_method :constantize, & TestLib_::Constantize_proc[]

   attr_accessor :do_debug

   def debug!
     @do_debug = true
   end

   infostream = ::STDERR

   define_method :infostream do infostream end
  end
end
