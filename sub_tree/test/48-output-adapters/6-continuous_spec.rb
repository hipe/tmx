require_relative '../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] output adapters - minimal" do

    TS_[ self ]

    it "works" do

      io = Home_::Library_::StringIO.new

      _tree = __build_tree

      Home_::Output_Adapters_::Continuous.with(

        :upstream_tree, _tree,
        :output_line_downstream_yielder, io,
        :info_line_downstream_yielder, debug_IO,
        :do_verbose_lines, do_debug )

      exp = <<-HERE.unindent
        one
        ├── two_A
        │  └── three
        └── two_B
      HERE

      act = io.string

      if do_debug
        debug_IO.puts "(ACT:#{ act })\n(EXP:#{ exp })"
      end

      act.should eql exp
    end

    def __build_tree

      cls = Output_Adapters::Node

      cls.new( :one,
        [ cls.new( :two_A, [ cls.new( :three ) ] ),
          cls.new( :two_B ) ] )
    end

    module Output_Adapters  # our own sandbox namespace

      class Node

        def initialize name_i, a=nil
          @a = a
          @name_symbol = name_i
        end

        def express_tree_against q

          q.node_label @name_symbol

          if @a
            q.branch do
              @a.each do | node |
                node.express_tree_against q
              end
            end
          end

          NIL_
        end
      end
    end
  end
end
