require_relative '../../../test-support'  # keep this as nearest

module Skylab::SubTree::TestSupport
  module API
    module Actions
      # remove these as possible
    end
  end
end

module Skylab::SubTree::TestSupport::API::Actions::My_Tree

  ::Skylab::SubTree::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  SubTree = SubTree
  TestSupport = TestSupport

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def start_front_with_upstream io
      start_front io
    end

    def start_front up=nil
      f = SubTree::API::Actions::My_Tree.new
      @o = TestSupport::IO::Spy.standard
      @e = TestSupport::IO::Spy.standard
      if do_debug
        @o.debug! 's-tdout; '
        @e.debug! 's-tderr: '
      end
      f.absorb :param_h, { }, :upstream, up, :paystream, @o, :infostream, @e
      f
    end

    def fixtures_dir_pn
      Fixtures_dir_pn_.call
    end
    Fixtures_dir_pn_ = -> do
      SubTree::Test_Fixtures.dir_pathname
    end
  end
end
