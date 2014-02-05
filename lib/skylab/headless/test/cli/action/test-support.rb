require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI::Action

  ::Skylab::Headless::TestSupport::CLI[ self ]

  include CONSTANTS

  Headless = Headless ; TestSupport = TestSupport

  module ModuleMethods

    def with_action_class i=nil, &p
      i ? dfn_actncls_with_i_and_p( i, p ) : dfn_actn_cls_with_p( p )
    end

    def dfn_actn_cls_with_p cls_p
      test_ctx = self
      before :all do
        cls = cls_p.call
        test_ctx.send :define_method, :action_class do cls end
      end
    end

    def dfn_actncls_with_i_and_p cls_i, cls_p
      define_method :action_class, Headless::Library_::Memoize[ -> do
        cls = start_class cls_i
        Headless::CLI::Action[ cls, :core_instance_methods ]
        cls.class_exec( & cls_p ) ; cls
      end ]
    end

    def action_class_with_DSL cls_i, & cls_p
      define_method :action_class, Headless::Library_::Memoize[ -> do
        cls = start_class cls_i
        cls.instance_variable_set :@dir_pathname, false
        Headless::CLI::Action[ cls, :DSL, :core_instance_methods ]
        cls.class_exec( & cls_p ) ; cls
      end ]
    end

    def start_class cls_i
      sandbox_module.const_set cls_i, ::Class.new
    end
  end

  module InstanceMethods

    def invoke * x_a
      _a = CONSTANTS::Normalize_argv[ x_a ]
      _ag = action
      @result = _ag.invoke _a
    end

    def action
      @action ||= build_hot_action
    end

    def build_hot_action
      _mock_client = mock_client
      _cls = action_class
      _cls.new _mock_client
    end

    def serr_a_bake_notify
      @mock_client.release
    end
  end
end
