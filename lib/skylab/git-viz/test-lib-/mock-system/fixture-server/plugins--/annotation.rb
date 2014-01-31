module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::Annotation  # this way we can keep chatty informational
      # messages (and support) from cluttering the body of the sever, but
      # still have them

      def initialize host
        @host = host
        @port_d = host.port_d
        serr_p = host.stderr_reference
        @y = ::Enumerator::Yielder.new do |msg|
          serr_p[].puts msg ; @y
        end
      end

      def on_beginning_of_loop
        @y << "fixture server running #{ rb_environment_moniker } #{
          }listening on port #{ @port_d }"
      end

      def on_end_of_loop
        _ec = @host.tentative_result_code
        @y << "(fixture server exiting with status #{ _ec })"
      end

    private

      def rb_environment_moniker
        "#{ rb_engine_moniker } #{ ::RUBY_VERSION }"
      end

      def rb_engine_moniker
        s = ::RUBY_ENGINE
        case s
        when 'ruby';'MRI ruby'
        else ; "#{ s } ruby"
        end
      end
    end
  end
end
