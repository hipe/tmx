require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib

  Parent__ = ::Skylab::GitViz::TestSupport  # except for when we use <- this..

  # ~
  # we are a child node by position only - we don't want to pull in
  # assets from the parent node. to this end, we do a lot manually:

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  _ = ::File.join ::Skylab::GitViz::TestSupport.dir_pathname.to_path, 'test-lib'

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, _ ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do
      h = {}
      -> sym do
        ( h.fetch sym do

          x = TestSupport_.fancy_lookup sym, TS_

          h[ sym ] = x
        end )[ self ]
      end
    end.call

    define_method :dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE
  end

  module InstanceMethods

    def new_string_IO_
      LIB_.string_IO.new
    end
  end

  Expect_Line = -> tcc do

    TestSupport_::Expect_line[ tcc ]
  end

  module LIB_ ; class << self

    def basic
      @__basic ||= Autoloader_.require_sidesystem( :Basic )
    end

    def plugin
      Autoloader_.require_sidesystem :Plugin
    end

    def string_IO
      @__string_IO ||= Autoloader_.require_stdlib( :StringIO )
    end

  end ; end

  # ~ shorties

  NIL_ = nil

  Subject_module_ = -> do
    ::Skylab::GitViz::Test_Lib_
  end
end
