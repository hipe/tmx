class Skylab::TestSupport::Regret::API::Actions::DocTest

  class Comment_::Block

    def initialize a
      @a = a
    end

    attr_reader :a

    def describe_to io
      @a.each do |x|
        io.puts x.describe
      end
      nil
    end

    -> do
      hack_rx = /\G[ ][ ][ ][ ].*#{ ::Regexp.escape SEP }/

      define_method :does_look_testy do
        @a.detect do |c|
          hack_rx.match c.line, c.col
        end
      end
    end.call
  end

  class Comment_::Block::Scanner < Comment_::Scanner_

    # this thing turns a filehandle into a series of zero or more comment
    # blocks, where a comment block is defined as two or more contiguous
    # lines with comments on them anywhere. just to keep things interesting,
    # it is coupled with the flyweighting of comment scanner.

    def initialize sn, fh
      a = [ ] ; cbcount = 0  # (the order of the below is in functional
      flush = -> do          #  reverse narrative.)
        cbcount += 1
        sn.do_medium and _report_flush( sn, cbcount, a )
        cb = Comment_::Block.new a
        a = [ ]
        cb
      end
      cfly = comment = func = one = nil
      post_two = -> c do    # any comment line after the second, if it follows
        if comment.no + 1 == c.no  # the previous, simply keep going as so.
          a << ( comment = c.collapse )
          nil               # nil because we are still going.
        else                # otherwise, we have what's definitely the end of
          cb = flush[]      # the active block, and what's possibly the start
          one[ c ]          # of a new block. (this call sets `func`.)
          cb                # this result tells the loop we can yield this item
        end
      end
      two = -> c do         # any second coment line that we get, if it
        if cfly.no + 1 == c.no  # immediately follows the previous comment,
          a << cfly.collapse ; cfly = nil  # store them both (while making
          a << ( comment = c.collapse )  # sure to collapse the flyweights!)
          func = post_two
        else                # otherwise, we reset the process.
          cfly = c          # note that `func` stays as `two`!
        end
        nil                 # nil because we are still going.
      end
      one = func = -> c do  # any first comment line that we ever get, it
        cfly = c            # means nothing to us, see? nothing. we just
        func = two          # hold on to it. note that it is a flyweight.
        nil                 # this result tells the loop we are still going.
      end
      hot = true
      finish = -> do
        fh.close
        hot = false
        a.length > 1 and flush[]
      end
      cs = Comment_::Scanner[ sn, Face::Services::Basic::List::Scanner[ fh ] ]
      @gets = -> do
        if hot
          while true
            cmnt = cs.gets or break ( r = finish[] )
            r = func[ cmnt ] and break
          end
          r
        end
      end
    end

  private

    def _report_flush sn, cnt, a
      sn.say :medium, -> do
        "(flushing comment block ##{ cnt } (#{ a.length } lines))"
      end
      nil
    end
  end
end
