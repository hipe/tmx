require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Porcelain::TestSupport

  ::Skylab::TestSupport::Regret[ Porcelain_TestSupport = self ]

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module TestLib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    Constantize_proc = -> do
      Callback_::Name.lib.constantize
    end

    HL__ = sidesys[ :Headless ]

    MH___ = sidesys[ :MetaHell ]

    Method_is_defined_by_module = -> i, mod do
      MH___[].method_is_defined_by_module i, mod
    end

    String_lib = -> do
      Basic[]::String
    end
  end

  Porcelain_ = ::Skylab::Porcelain

  module ModuleMethods

    include Constants

    include Porcelain_.lib_.basic::Class::Creator::ModuleMethods  # `klass!` etc

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

   include Constants

   include Porcelain_.lib_.basic::Class::Creator::InstanceMethods  # for `klass!`

   define_method :style_free, TestLib_::CLI_lib[].pen.unstyle

   define_method :unstyle_styled, TestLib_::CLI_lib[].pen.unstyle_styled

   define_method :constantize, & TestLib_::Constantize_proc[]

   attr_accessor :do_debug

   def debug!
     @do_debug = true
   end

   infostream = ::STDERR

   define_method :infostream do infostream end
  end

  module Constants
    Bleeding = Porcelain_::Bleeding  # :+#wontfix
    Callback_ = Callback_
    Porcelain_ = ::Skylab::Porcelain
    TestLib_ = TestLib_
    TestSupport_ = TestSupport_
  end
end
