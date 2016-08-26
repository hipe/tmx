module Skylab::TestSupport

  module CLI

    class << self

      def new sin, sout, serr, pn_s_a

        Require_zerk_[]

        cli = Zerk_::NonInteractiveCLI.begin

        cli.universal_CLI_resources sin, sout, serr, pn_s_a

        cli.node_map = {
          file_coverage: -> do
            Home_::FileCoverage::Modalities::CLI::NODE_MAP
          end,
        }

        cli.expression_agent = CLI::Expression_Agent.instance__

        yield cli

        fs_p = cli.filesystem_proc or CLI._SANITY

        cli.root_ACS_by do
          Home_::API::Root_Autonomous_Component_System.new fs_p
        end

        cli.finish
      end

      def visual_client
        CLI::Visual_Client___
      end
    end  # >>

    Lazy_ = Common_::Lazy

    Require_zerk_ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk ; nil
    end
  end
end
# #tombstone: 2 CLI-related near-toplevel files with long history
