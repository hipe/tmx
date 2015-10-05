module Skylab::TestSupport

  module API

    Brazen_ = Autoloader_.require_sidesystem :Brazen

    class << Home_

      # sketchy #stowaway: only when the [ts] interactive API is being called
      # do we need the below, for support of procs as actions:

      def action_base_class
        Brazen_::Model.common_action_class
      end
    end  # >>

    class << self

      define_method :krnl, ( Callback_.memoize do
        Home_.lib_.brazen::Kernel.new Home_
      end )
    end  # >>

    module Home_::Models_

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
  end
end
