module Skylab::GitViz

  module CLI

    class Actions__::Ping < Action_

      def invoke_with_iambic x_a
        invoke_API_with_iambic x_a
        :hello_from_git_viz
      end
    end
  end
end
