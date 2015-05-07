module Skylab::System

  module TestSupport_Visual

    class Services::Filesystem::Path_Tools < Client_

      def usage_line
        "#{ super } (will run test)"
      end

      def usage_args
      end

      def when_no_args
        require_relative 'pretty-path/visual'
        NIL_
      end
    end
  end
end
