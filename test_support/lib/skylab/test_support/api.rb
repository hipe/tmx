module Skylab::TestSupport

  module API

    class << self

      def call * x_a, & oes_p

        # don't ever write events to stdout / stderr by default.

        if oes_p
          x_a.push :on_event_selectively, oes_p
        elsif x_a.length < 2 || :on_event_selectively != x_a[ -2 ]
          x_a.push :on_event_selectively, -> i, *, & ev_p do
            if :error == i
              raise ev_p[].to_event.to_exception
            end
          end
        end

        bc = application_kernel_.bound_call_via_mutable_iambic x_a
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def application_kernel_
        Home_.lib_.brazen::Kernel.new API
      end

      def expression_agent_class
        Home_.lib_.brazen::API.expression_agent_class
      end

      yes = true ; x = nil
      define_method :kernel__ do
        if yes
          yes = false
          x = Brazen_::Kernel.new API
        end
        x
      end
    end  # >>

    module Models_

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
          y << "hello from #{ kr.app_name }#{ _x }\n"
        end

        :hello_from_test_support
      end

      Autoloader_[ self, :boxxy ]
    end

    Brazen_ = Home_.lib_.brazen
  end
end
