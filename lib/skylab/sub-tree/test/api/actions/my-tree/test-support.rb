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

  module CONSTANTS

    NIL_A_ = [ nil ].freeze

    PRETTY_ = <<-HERE.unindent
      one
      ├── foo.rb
      └── test
          └── foo_spec.rb
    HERE

  end

  extend TestSupport::Quickie

  SubTree = SubTree
  TestSupport = TestSupport

  module InstanceMethods

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
      f._FIXME_15_with_ :param_h, { }, :upstream, up, :paystream, @o, :infostream, @e
      f
    end

    def fixtures_dir_pn
      Fixtures_dir_pn_.call
    end
    Fixtures_dir_pn_ = -> do
      SubTree::Test_Fixtures.dir_pathname
    end

    def line
      @a.shift or fail "expected more lines, had none"
    end

    def expect_no_more_lines
      @a.length.zero? or fail "expected no more lines - #{ @a[ 0 ] }"
    end
  end
end
