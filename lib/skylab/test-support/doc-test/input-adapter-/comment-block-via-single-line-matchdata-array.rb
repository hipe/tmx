module Skylab::TestSupport

  module Regret::API

  class Actions::DocTest

  class Comment_

    RegretLib_::Pool[ self ].with_lease_and_release -> do
      new
    end

    def set * a
      @line, @no, @col = a
      nil
    end

    attr_reader :line, :no, :col


    def clear_for_pool
      # be careful
    end

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

        Stream_ = RegretLib_::Ivars_with_procs_as_methods[].new :gets do
          class << self
            alias_method :[], :new
          end
        end

        class Stream < Stream_

          def initialize _snitch, lines
            hack_rx = /[ ][ ]#(?:[ ]|$)/
            c_a = [ Comment_.lease, Comment_.lease ]
            base = c_a.length ; idx = -1
            func = -> line do
              if hack_rx =~ line
                x = c_a.fetch( idx = ( idx + 1 ) % base )  # it's tivo
                x.set line, lines.count, $~.offset( 0 ).last
                x  # (the offset of the end of the capture is the start of content)
              end
            end
            hot = true
            finish = -> do
              c_a.each do |x|
                Comment_.release x
              end
              hot = false
            end
            @gets = -> do
              while hot
                line = lines.gets
                line or break finish[]
                x = func[ line ]
                x and break
              end
              x
            end
          end
        end
  end
  end
  end
end
