module Skylab::TestSupport

  module API

    Brazen_ = Autoloader_.require_sidesystem :Brazen

    class << TestSupport_

      # sketchy #stowaway: only when the [ts] interactive API is being called
      # do we need the below, for support of procs as actions:

      def action_class
        Brazen_.model.action_class
      end
    end  # >>

    class << self

      define_method :krnl, ( Callback_.memoize do
        TestSupport_.lib_.brazen::Kernel.new TestSupport_
      end )

      def lib_
        @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib___, self
      end
    end  # >>

    module TestSupport_::Models_

      Ping = -> * rest, mock_bound_action, & oes_p do

        if 1 == rest.length && rest.first.nil?
          rest.clear  # meh
        end

        kr = mock_bound_action.kernel

        _x = if rest.length.nonzero?
          ": #{ rest.inspect }"
        else
          '.'
        end

        oes_p.call :info, :expression, :ping do | y |
          y << "hello from #{ kr.app_name.gsub SPACE_, DASH_ }#{ _x }\n"
        end

        :"hello_from_test-support"
      end

      Autoloader_[ self, :boxxy ]
    end

    module Lib___

      sidesys = Autoloader_.build_require_sidesystem_proc

      CLI_lib = -> do
        HL__[]::CLI
      end

      EN_add_methods = -> mod, * x_a do
        HL__[].expression_agent.NLP_EN_methods.on_mod_via_iambic mod, x_a
      end

      HL__ = sidesys[ :Headless ]

      Ick = -> x do
        MH__[].strange x
      end

      MH__ = sidesys[ :MetaHell ]

      Name_symbol_to_label = -> i do
        HL__[]::Name.labelize( i ).downcase
      end

      Pretty_path_proc = -> do
        HL__[].system.filesystem.path_tools.pretty_path
      end
    end
  end
end
