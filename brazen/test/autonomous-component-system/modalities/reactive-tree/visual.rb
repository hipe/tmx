module Skylab::Brazen

  module TestSupport_Visual

    class Autonomous_Component_System::Modalities::Reactive_Tree < Client_

      def when_no_args
        self
      end

      def display_usage
        self
      end

      def execute

        _tsmod = Home_.test_support.lib(
          :autonomous_component_system_modalities_reactive_tree_CLI_integration_support
        )

        _ke = _tsmod.kernel_

        _cli = Home_::CLI.new(
          @stdin, @stdout, @stderr,
          [ 'hi' ],
          :back_kernel, _ke,
        )

        _cli.invoke @argv
      end


      Here_ = self
    end
  end
end
