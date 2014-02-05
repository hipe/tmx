require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  ::Skylab::Headless::TestSupport::CLI::Box[ TS__ = self ]

  include CONSTANTS

  Headless = Headless ; QUEUE_IVAR__ = QUEUE_IVAR

  extend TestSupport::Quickie

  module ModuleMethods

    def box_DSL_class cls_i, & cls_p

      define_method :box_DSL_class, Headless::Library_::Memoize[ -> do
        _cls = sandbox_module.const_set cls_i, ::Class.new
        _cls.class_exec do
          Headless::CLI::Box[ self, :DSL ]
          module_exec( & cls_p )
          self
        end
      end ]
    end
  end

  module InstanceMethods

    # ~ setup phase

    def box_class
      box_DSL_class
    end


    # ~ test phase

    def expect_usage_line_ending_with s
      expect :styled, /\Ausage: yerp #{ ::Regexp.escape s }\z/
    end

  end
end
