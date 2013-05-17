class Skylab::TestSupport::Regret::API::Actions::DocTest

  class Comment_

    MetaHell::Pool.enhance( self ).with_lease_and_release -> do
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
      @line = nil  # just for volume
      otr
    end
  end

  Comment_::Scanner_ = MetaHell::Function::Class.new :gets
  class Comment_::Scanner_  # base class

    def self.[] *a  # for debugging something
      new( *a )
    end
  end

  class Comment_::Scanner < Comment_::Scanner_

    def initialize lines
      hot = true
      ci_a = [ Comment_.lease, Comment_.lease ] ; i = 0 ; mode = ci_a.length
      finish = -> do
        ci_a.each { |x| Comment_.release x }
        hot = false
      end
      hack_rx = /[ ][ ]#(?:[ ]|$)/
      start = -> line do
        if hack_rx =~ line
          ci = ci_a.fetch( i = ( i + 1 ) % mode )  # it's tivo
          ci.set line, lines.count, $~.offset( 0 ).last
          ci
        end
      end
      current = start
      @gets = -> do
        if hot
          r = nil
          while true
            line = lines.gets or break finish[]
            r = current[ line ] and break
          end
          r
        end
      end
    end
  end
end
