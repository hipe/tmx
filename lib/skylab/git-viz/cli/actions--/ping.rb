module Skylab::GitViz

  module CLI

    class Actions__::Ping < Action_

      def invoke_with_iambic x_a
        _m_i = x_a.length.zero? ? :emit_info_line : :emit_payload_line
        send _m_i, "hello from git viz." ; false and  # #todo:during:4
        invoke_API_with_iambic x_a
        :hello_from_git_viz
      end
    end
  end
end
