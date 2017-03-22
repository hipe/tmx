module Skylab::Human

  module NLP::EN::Tricks
  end

  module NLP::EN::Tricks::Cycle
  end

  NLP::EN::Tricks::Cycle::Terminal = -> do
    -> arr, param_h=nil do
      rand = nil
      if param_h
        param_h_h = { rand: -> v { rand = v } }
        param_h.each { |k, v| param_h_h.fetch( k )[ v ] }
      end
      pool_a = arr.length.times.to_a
      if rand
        x = rand < 0 ? 0 : [ rand, arr.length ].min
        pool_a[ 0, x ] = x.times.to_a.shuffle
      end
      if pool_a.length.zero?
        gets = -> { }
      else
        current = 0
        last = pool_a.length - 1
        gets = -> do
          res = arr.fetch pool_a.fetch current
          if current == last
            idx = pool_a.fetch current
            gets = -> do
              arr.fetch idx
            end
          else
            current += 1
          end
          res
        end
      end
      -> do
        gets[]
      end
    end
  end.call
end
