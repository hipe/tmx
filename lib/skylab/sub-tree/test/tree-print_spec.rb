require_relative 'test-support'

module Skylab::SubTree::TestSupport::Tree_Print

  ::Skylab::SubTree::TestSupport[ TS__ = self ]

  SubTree = ::Skylab::SubTree

  describe "[st] tree-print" do

    extend TS__

    it "o" do
      io = SubTree::Services::StringIO.new
      SubTree::Tree_Print.tree_print get_object, io, :do_verbose_lines,
        do_debug, :info_p, debug_stream.method( :puts )
      _exp = <<-HERE.unindent
        one
        ├── two_A
        │  └── three
        └── two_B
      HERE
      _act = io.string
      do_debug and debug_stream.puts "(ACT:#{ _act })\n(EXP:#{ _exp })"
      _act.should eql _exp
    end

    def get_object
      Node.new( :one,
        [ Node.new( :two_A, [ Node.new( :three ) ] ),
          Node.new( :two_B ) ] )
    end

    class Node
      def initialize name_i, a=nil
        @a = a ; @name_i = name_i ; nil
      end
      def tree_print q
        q.node_label @name_i
        if @a
          q.branch do
            @a.each do |node|
              node.tree_print q
            end
          end
        end ; nil
      end
    end
  end
end
