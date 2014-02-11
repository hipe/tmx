class Skylab::TestSupport::Regret::API::Actions::DocTest

  class Comment_

    RegretLib_::Pool[ self ].with_lease_and_release -> do
      new
    end

    def set line, no, col
      @line, @no, @col = line, no, col
      nil
    end

    attr_reader :line, :no, :col

    -> do
      fmt = '%3d'
      define_method :describe do
        "#{ fmt % @no }: <<#{ '.' * ( @col - 1 ) if @col.nonzero? }#{
          @line[ @col .. -1 ].chomp
        }>>"
      end
    end.call

    def collapse
      otr = self.class.lease
      otr.set @line, @no, @col
      @line = @no = @col = nil  # sanity
      otr
    end
  end

  Comment_::Scanner_ = RegretLib_::Procs_as_methods.call :gets do
    class << self
      alias_method :[], :new
    end
  end

  class Comment_::Scanner < Comment_::Scanner_

    def initialize _snitch, lines
      hack_rx = /[ ][ ]#(?:[ ]|$)/
      c_a = [ Comment_.lease, Comment_.lease ] ; base = c_a.length ; idx = -1
      func = -> line do
        if hack_rx =~ line
          r = c_a.fetch( idx = ( idx + 1 ) % base )  # it's tivo
          r.set line, lines.count, $~.offset( 0 ).last
          r  # (the offset of the end of the capture is the start of content)
        end
      end
      hot = true
      finish = -> do
        c_a.each { |x| Comment_.release x }
        hot = false
      end
      @gets = -> do
        if hot
          while true
            line = lines.gets or break finish[]
            r = func[ line ] and break
          end
          r
        end
      end
    end
  end
end
