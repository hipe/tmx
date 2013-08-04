require_relative '../test-support'

module Skylab::SubTree::TestSupport::API::Actions::My_Tree::Rendering

  ::Skylab::SubTree::TestSupport::API::Actions::My_Tree[ TS_ = self ]

  include CONSTANTS

  SubTree = SubTree

  extend TestSupport::Quickie

  module InstanceMethods

    include CONSTANTS

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def with str
      @with = str.unindent.chomp
      nil
    end

    def makes str
      o = TestSupport::IO::Spy.new
      e = ( do_debug and TestSupport::Stderr_[] )
      do_debug and o.debug! "s-tdout: "
      t = SubTree::API::Actions::My_Tree::Traversal_.new(
        :out_p, o.method( :puts ),
        :do_verbose_lines, do_debug,
        :info_p, ( do_debug and e.method( :puts ) ) )
      @with.split( "\n" ).each do |s|
        t.puts s
      end
      t.flush_notify
      nil
    end
  end
end
