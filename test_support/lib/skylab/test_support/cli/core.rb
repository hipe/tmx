module Skylab::TestSupport

  module CLI

    class << self

      def new argv, sin, sout, serr, pn_s_a, & p

        Require_zerk_[]

        cli = Zerk_::NonInteractiveCLI.begin

        cli.argv = argv

        cli.universal_CLI_resources sin, sout, serr, pn_s_a

        cli.node_map = {
          file_coverage: -> do
            Home_::FileCoverage::CLI::NODE_MAP
          end,
          permute: -> o do
            Home_::Permute::CLI::Node_mappings_for_permute_operation[ o ]
          end,
        }

        cli.expression_agent = CLI::ExpressionAgent.instance__

        if 1 == p.arity  # yuck - better for testing..
          yield cli
          fs_p = cli.filesystem_proc
          fs_p || CLI._SANITY

        else  # ..better for mouting:
          up_cli = yield

          fs_p = up_cli.filesystem_proc
          fs_p || CLI._SANITY

          cli.write_exitstatus = up_cli.method :exitstatus=
        end

        cli.root_ACS_by do
          Home_::API::Root_Autonomous_Component_System.new fs_p
        end

        cli.finish
      end

      def visual_client
        CLI::Visual_Client___
      end
    end  # >>
  end
end
# #tombstone: 2 CLI-related near-toplevel files with long history
