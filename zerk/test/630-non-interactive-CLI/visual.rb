module Skylab::Zerk

  module TestSupport_Visual

    class Zerk::Modalities::Reactive_Tree < Client_

      def when_no_args
        self
      end

      def display_usage
        self
      end

      def execute

        br = Home_.lib_.brazen

        _tsmod = br.test_support.lib(
          :autonomous_component_system_modalities_reactive_tree_CLI_integration_support
        )

        _ke = _tsmod.kernel_

        _cli = br::CLI.new(
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
