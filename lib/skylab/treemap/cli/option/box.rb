module Skylab::Treemap

  class CLI::Option::Box

    def add opt
      if @hash.key? opt.normalized_name
        fail "haha no way - we are add-only, no clobber - #{
          }#{ opt.normalized_name }"
      end
      @order.push opt.normalized_name
      @hash[opt.normalized_name] = opt
      nil
    end

    def clear!
      # note it does not clear the hash itself!
      @by_switch_h = nil
      nil
    end

    def fetch_by_normalized_name normalized_name, &block
      @hash.fetch( normalized_name, &block )
    end

    alias_method :[], :fetch_by_normalized_name # not guaranteeed to stick

    def fetch_by_switch switch, &block
      @by_switch_h ||= begin
        @order.reduce( {} ) do |m, nn|
          opt = @hash[nn]
          m[ opt.render_short ] = nn if opt.has_short
          m[ opt.render_long_no_no  ] = nn if opt.has_long
          m[ opt.render_long ] = nn if opt.takes_no
          m
        end
      end
      res = nil
      nn = @by_switch_h.fetch switch do |k|
        if block
          res = block[ k ]
          nil
        else
          raise ::KeyError.new "key no found: #{ k.inspect }"
        end
      end
      if nn
        res = @hash.fetch nn
      end
      res
    end

    def fuzzy_fetch x, &block
      res = nil
      x = x.to_s
      if '-' == x[0]
        res = fetch_by_switch x, &block
      else
        res = fetch_by_normalized_name x.intern, &block
      end
      res
    end

  protected

    def initialize
      @order = [ ]
      @hash = { }
      @by_switch_h = nil
    end
  end
end
