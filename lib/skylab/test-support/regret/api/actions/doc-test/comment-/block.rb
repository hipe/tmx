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

    def initialize fh
      ln = Face::Services::Basic::List::Scanner[ fh ]  # lines
      cm = Comment_::Scanner[ ln ]
      hot = true ; prev_line = store = flush = nil ; a = [ ]
      finish = -> do
        fh.close
        hot = false
        flush[ ]
      end
      two = three = nil  # `two` = opposite end of `penultimate`
      current = one = -> c do
        prev_line = c
        current = two
        nil
      end
      two = -> c do
        if c.no == prev_line.no + 1  # two contiguous comment lines.
          current = three
          store[ prev_line ]
          store[ prev_line = c ]
        else
          # the second line we read was not contiguous with the prev,
          # ditch prev.
          prev_line = c
        end
        nil
      end
      store = -> c do
        a << c.collapse
        nil
      end
      three = -> c do
        if c.no == prev_line.no + 1
          store[ prev_line = c ]
          nil
        else
          x = flush[]
          one[ c ]
          x
        end
      end
      flush = -> do
        if a.length > 1
          x = Comment_::Block.new a
          a = [ ]
          x
        end
      end
      @gets = -> do
        if hot
          r = nil
          while true
            item = cm.gets or break ( r = finish[] )
            r = current[ item ] and break
          end
          r
        end
      end
    end
  end
end
