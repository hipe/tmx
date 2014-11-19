module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::Annotation  # this way we can keep chatty informational
      # messages (and support) from cluttering the body of the sever, but
      # still have them

      def initialize host
        @host = host ; human_name_ = "#{ host.server_name.as_human } "
        @port_d = host.port_d
        serr_p = host.stderr_reference
        @y = ::Enumerator::Yielder.new do |msg|
          msg = Msg__.new msg
          msg.agent_prefix = human_name_
          serr_p[].puts msg.to_s ; @y
        end
      end

      Msg__ = GitViz._lib.plugin::Qualifiable_Message_String

      def on_intro
        @y << "(running #{ rb_environment_moniker })"
      end

      def on_beginning_of_loop
        @y << "listening on port #{ @port_d }"
      end

      def on_end_of_loop ec
        @y << "(exiting with status #{ ec })"
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
