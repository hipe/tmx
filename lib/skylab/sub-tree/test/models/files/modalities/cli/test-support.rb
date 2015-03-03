require_relative '../test-support'

module Skylab::SubTree::TestSupport::API::Actions::My_Tree::Rendering

  ::Skylab::SubTree::TestSupport::API::Actions::My_Tree[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  SubTree_ = SubTree_

  module InstanceMethods

    include Constants

    def with str
      @with = str.unindent.chomp
      nil
    end

    def makes str
      o = TestSupport_::IO.spy(
        :do_debug_proc, -> { do_debug },
        :debug_IO, debug_stream )
      do_debug and o.debug! "s-tdout: "
      t = SubTree_::API::Actions::My_Tree::Traversal_.new(
        :out_p, o.method( :puts ),
        :do_verbose_lines, do_debug,
        :info_p, ( do_debug and e.method( :puts ) ) )
      @with.split( "\n" ).each do |s|
        t.puts s
      end
      t.flush
      nil
    end
  end
end
