module Skylab::SubTree

  class API::Actions::My_Tree::Extensions_

    SubTree::Library_.touch :Shellwords

    class Line_Count_

      Lib_::Fields[ self, :local_normal_name, :infostream, :verbose ]

      attr_reader :local_normal_name

      def is_post_notifiee
        true
      end

      def post_notify row_a
        leaves = row_a.reduce [] do |m, row|
          (( lf = row.any_leaf )) or next m
          m << lf
        end
        cmd = "wc -l #{ leaves.map { |lf| lf.input_line.shellescape } * ' ' }"
        @verbose.volume.nonzero? and @infostream.puts cmd
        _, o, e, w = SubTree::Library_::Open3.popen3 cmd
        if (( err = e.read )) && '' != err
          o.read  # toss
          es = w.value.exitstatus
          @infostream.puts "(find (existatus #{ es }) wrote to #{
            }errstream - #{ err })"
        else
          mutate_leaves_with_find_results leaves, o, w
        end
        nil
      end

    private

      def mutate_leaves_with_find_results leaves, o, w
        h = prepare_find_results leaves, o, w
        leaves.each do |lf|
          d = h.fetch lf.input_line
          lf.add_attribute :line_count, d
          lf.add_subcel "#{ d } line#{ 's' if 1 != d }"
        end
        nil
      end

      def prepare_find_results leaves, o, w
        h = { } ; prev_line = o.gets  # edge cases - there might be a file
        while true  # called `total`, there might be only 1 file
          if ! (( line = o.gets ))
            h.length.nonzero? and break
            stop = true
          end
          md = RX_.match prev_line
          h[ md[ :file ] ] = md[ :num_lines ].to_i
          stop and break
          prev_line = line
        end
        es = w.value.exitstatus
        @verbose.volume.nonzero? and @infostream.puts "(find exitstatus #{es})"
        h
      end
      #
      RX_ = /\A[ ]*(?<num_lines>\d+)[ ]+(?<file>[^ \n].*[^\n])\n?\z/
    end
  end
end
