module Skylab::TestSupport

  module Quickie

    class Run_

      def initialize svc
        @do_recursive = nil
        @svc = svc
      end

      attr_writer :do_recursive

      def invoke argv
        @do_recursive or fail "sanity - recursive only for now."
        if (( bm = Quickie::Multi_::Client_.new( @svc ).resolve argv ))
          bm.receiver.send bm.name
        end
      end
    end
  end
end
